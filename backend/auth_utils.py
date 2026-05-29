from firebase_admin import auth
from firebase_admin import firestore
from firebase_config import db # Importamos la instancia de Firestore

# --- Funciones de Autenticación y Gestión de Usuarios ---

def create_firebase_user_and_profile(email, password, display_name, phone_number=None):
    """
    Crea un nuevo usuario en Firebase Authentication y guarda su perfil inicial en Firestore.
    Retorna el UID del usuario si tiene éxito, None en caso de error.
    """
    try:
        # 1. Crear usuario en Firebase Authentication
        # El numero de telefono es opcional en Firebase Auth si no se usa para iniciar sesion directamente
        user_properties = {
            'email': email,
            'password': password,
            'displayName': display_name
        }
        if phone_number:
            user_properties['phoneNumber'] = phone_number

        user = auth.create_user(**user_properties)
        user_id = user.uid

        # 2. Crear documento de perfil en Cloud Firestore
        user_ref = db.collection('users').document(user_id)
        user_ref.set({
            'email': email,
            'nombre': display_name,
            'telefono': phone_number, # Guarda el teléfono también en Firestore
            'fecha_registro': firestore.SERVER_TIMESTAMP,
            'ultimo_acceso': firestore.SERVER_TIMESTAMP,
            'nivel_violencia_actual': 'verde' # Valor inicial
        })
        print(f"Usuario {email} creado en Auth y perfil en Firestore con UID: {user_id}")
        return user_id
    except auth.EmailAlreadyExistsError:
        print(f"Error: El email {email} ya está registrado.")
        return "Email already exists"
    except Exception as e:
        print(f"Error al crear usuario o perfil: {e}")
        return None

def verify_id_token(id_token):
    """
    Verifica un ID Token de Firebase.
    Retorna el diccionario de datos decodificados del token si es válido, None si no lo es.
    """
    try:
        # verify_id_token verifica la firma, la expiración, el emisor y la audiencia del token.
        # También asegura que el token no ha sido revocado.
        decoded_token = auth.verify_id_token(id_token)
        print(f"Token verificado para UID: {decoded_token['uid']}")
        return decoded_token
    except Exception as e:
        print(f"Error al verificar token: {e}")
        return None

def get_user_by_email_for_login(email):
    """
    Intenta obtener un usuario por email para verificar su existencia.
    (Nota: El Admin SDK no valida contraseñas directamente para el login.
    El login se maneja en el cliente, que luego envía el ID Token al backend).
    Esta función es más para verificar si un email existe si se necesita antes de intentar un login en el cliente.
    """
    try:
        user = auth.get_user_by_email(email)
        return user.uid
    except auth.UserNotFoundError:
        print(f"Usuario con email {email} no encontrado.")
        return None
    except Exception as e:
        print(f"Error al obtener usuario por email: {e}")
        return None

# Puedes añadir más funciones aquí, como:
# - auth.delete_user(uid)
# - auth.update_user(uid, email='new@example.com')
# - auth.revoke_refresh_tokens(uid)
