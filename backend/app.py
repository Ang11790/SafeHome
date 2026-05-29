import os
import sys
from flask_cors import CORS
from flask import Flask, request, jsonify
from functools import wraps

app = Flask(__name__)
CORS(app)

# --- Importaciones de tus módulos Firebase ---
from .firebase_config import db
from .auth_utils import create_firebase_user_and_profile, verify_id_token
from .firestore_utils import (
    get_user_profile_from_firestore,
    update_user_profile_in_firestore,
    add_emergency_contact_to_firestore,
    get_emergency_contacts_from_firestore,
    delete_emergency_contact_from_firestore
)
from firebase_admin import firestore
from firebase_admin import auth

# --- Middleware de Autenticación (Decorador) ---
def firebase_auth_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get("Authorization")
        if not auth_header:
            return jsonify({
                "success": False,
                "message": "No se proporcionó token de autenticación. Acceso denegado."
            }), 401

        try:
            id_token = auth_header.split("Bearer ")[1]
            decoded_token = verify_id_token(id_token)
            if not decoded_token:
                return jsonify({
                    "success": False,
                    "message": "Token inválido, expirado o revocado. Vuelva a iniciar sesión."
                }), 401

            request.uid = decoded_token['uid']
            return f(*args, **kwargs)
        except IndexError:
            return jsonify({
                "success": False,
                "message": "Formato de token inválido. Use 'Bearer <id_token>'."
            }), 401
        except Exception as e:
            print(f"Error inesperado durante la autenticación: {e}")
            return jsonify({
                "success": False,
                "message": f"Error de autenticación interno: {e}"
            }), 500
    return decorated_function

# --- RUTAS DE AUTENTICACIÓN ---
@app.route("/api/auth/register", methods=["POST"])
def register_user():
    data = request.get_json(silent=True) or {}
    name = data.get("name")
    email = data.get("email")
    password = data.get("password")
    phone = data.get("phone")
    if not name or not email or not password:
        return jsonify({
            "success": False,
            "message": "Los campos 'name', 'email' y 'password' son requeridos."
        }), 400
    if len(password) < 6:
        return jsonify({
            "success": False,
            "message": "La contraseña debe tener al menos 6 caracteres."
        }), 400
    uid = create_firebase_user_and_profile(email, password, name, phone)
    if uid == "Email already exists":
        return jsonify({
            "success": False,
            "message": "Este email ya está registrado. Intente iniciar sesión."
        }), 409
    elif uid:
        return jsonify({
            "success": True,
            "message": "Usuario registrado exitosamente.",
            "uid": uid
        }), 201
    else:
        return jsonify({
            "success": False,
            "message": "Error interno al registrar usuario."
        }), 500

@app.route("/api/auth/login", methods=["POST"])
def login_user():
    data = request.get_json(silent=True) or {}
    id_token = data.get("idToken")
    if not id_token:
        return jsonify({
            "success": False,
            "message": "Se requiere el 'idToken' de Firebase Auth para verificar el inicio de sesión."
        }), 400
    decoded_token = verify_id_token(id_token)
    if decoded_token:
        uid = decoded_token['uid']
        update_user_profile_in_firestore(uid, {'ultimo_acceso': firestore.SERVER_TIMESTAMP})
        return jsonify({
            "success": True,
            "message": "Inicio de sesión verificado exitosamente.",
            "uid": uid,
            "email": decoded_token.get('email')
        }), 200
    else:
        return jsonify({
            "success": False,
            "message": "ID Token inválido, expirado o revocado."
        }), 401

# --- RUTAS PROTEGIDAS PARA EL PERFIL DE USUARIO ---
@app.route("/api/profile", methods=["GET"])
@firebase_auth_required
def get_profile():
    user_profile = get_user_profile_from_firestore(request.uid)
    if user_profile:
        return jsonify({
            "success": True,
            "data": user_profile
        }), 200
    else:
        return jsonify({
            "success": False,
            "message": "Perfil de usuario no encontrado."
        }), 404

@app.route("/api/profile/update", methods=["PUT"])
@firebase_auth_required
def update_profile():
    data = request.get_json(silent=True) or {}
    uid = request.uid
    updatable_fields = {}
    if 'name' in data:
        updatable_fields['nombre'] = data['name']
    if 'phone' in data:
        updatable_fields['telefono'] = data['phone']
    if not updatable_fields:
        return jsonify({
            "success": False,
            "message": "No se proporcionaron campos válidos para actualizar."
        }), 400
    if update_user_profile_in_firestore(uid, updatable_fields):
        return jsonify({
            "success": True,
            "message": "Perfil actualizado exitosamente."
        }), 200
    else:
        return jsonify({
            "success": False,
            "message": "Error al actualizar perfil de usuario."
        }), 500

# --- RUTAS PROTEGIDAS PARA CONTACTOS DE EMERGENCIA ---
@app.route("/api/user/contacts", methods=["POST"])
@firebase_auth_required
def add_contact():
    data = request.get_json(silent=True) or {}
    uid = request.uid
    contact_name = data.get('name')
    phone_number = data.get('phone')
    email = data.get('email')
    relation = data.get('relation')
    if not contact_name or not phone_number:
        return jsonify({
            "success": False,
            "message": "Los campos 'name' y 'phone' del contacto son requeridos."
        }), 400
    contact_id = add_emergency_contact_to_firestore(uid, contact_name, phone_number, email, relation)
    if contact_id:
        return jsonify({
            "success": True,
            "message": "Contacto de emergencia añadido exitosamente.",
            "contactId": contact_id
        }), 201
    else:
        return jsonify({
            "success": False,
            "message": "Error al añadir contacto de emergencia."
        }), 500

@app.route("/api/user/contacts", methods=["GET"])
@firebase_auth_required
def get_contacts():
    uid = request.uid
    contacts = get_emergency_contacts_from_firestore(uid)
    return jsonify({
        "success": True,
        "data": contacts
    }), 200

@app.route("/api/user/contacts/<string:contact_id>", methods=["DELETE"])
@firebase_auth_required
def delete_contact(contact_id):
    uid = request.uid
    if delete_emergency_contact_from_firestore(uid, contact_id):
        return jsonify({
            "success": True,
            "message": "Contacto de emergencia eliminado exitosamente."
        }), 200
    else:
        return jsonify({
            "success": False,
            "message": "Error al eliminar contacto de emergencia o no se encontró."
        }), 404

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)