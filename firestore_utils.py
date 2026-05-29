# firestore_utils.py
from firebase_admin import firestore
from firebase_config import db # Importamos la instancia de Firestore

# --- Funciones de Gestión de Perfil de Usuario en Firestore ---

def get_user_profile_from_firestore(user_id):
    """
    Obtiene el perfil de un usuario desde Firestore.
    Retorna un diccionario con los datos del perfil si existe, None si no.
    """
    try:
        user_ref = db.collection('users').document(user_id)
        doc = user_ref.get()
        if doc.exists:
            profile_data = doc.to_dict()
            profile_data['uid'] = doc.id # Añadir el UID al diccionario de retorno
            return profile_data
        else:
            return None
    except Exception as e:
        print(f"Error al obtener perfil del usuario {user_id} de Firestore: {e}")
        return None

def update_user_profile_in_firestore(user_id, data_to_update):
    """
    Actualiza el perfil de un usuario en Firestore.
    `data_to_update` debe ser un diccionario, por ejemplo: {'nombre': 'Nuevo Nombre', 'genero': 'no binario'}
    """
    try:
        user_ref = db.collection('users').document(user_id)
        user_ref.update(data_to_update)
        print(f"Perfil del usuario {user_id} actualizado en Firestore.")
        return True
    except Exception as e:
        print(f"Error al actualizar perfil del usuario {user_id} en Firestore: {e}")
        return False

# --- Funciones de Gestión de Contactos de Emergencia ---

def add_emergency_contact_to_firestore(user_id, contact_name, phone_number, email=None, relation=None):
    """
    Añade un contacto de emergencia para un usuario específico.
    Retorna el ID del nuevo contacto si tiene éxito, None en caso de error.
    """
    try:
        emergency_contacts_ref = db.collection('users').document(user_id).collection('emergencyContacts')
        new_contact_ref = emergency_contacts_ref.document() # Firestore generará un ID para el contacto

        contact_data = {
            'nombre_contacto': contact_name,
            'telefono': phone_number,
            'email': email,
            'relacion': relation,
            'añadido_en': firestore.SERVER_TIMESTAMP
        }
        new_contact_ref.set(contact_data)
        print(f"Contacto de emergencia '{contact_name}' añadido para el usuario {user_id} con ID: {new_contact_ref.id}")
        return new_contact_ref.id
    except Exception as e:
        print(f"Error al añadir contacto de emergencia para usuario {user_id}: {e}")
        return None

def get_emergency_contacts_from_firestore(user_id):
    """
    Obtiene todos los contactos de emergencia de un usuario desde Firestore.
    Retorna una lista de diccionarios de contactos.
    """
    try:
        contacts_ref = db.collection('users').document(user_id).collection('emergencyContacts')
        docs = contacts_ref.stream()
        contacts = []
        for doc in docs:
            contact = doc.to_dict()
            contact['id'] = doc.id # Incluir el ID del documento del contacto
            contacts.append(contact)
        print(f"Contactos de emergencia para {user_id}: {contacts}")
        return contacts
    except Exception as e:
        print(f"Error al obtener contactos de emergencia para usuario {user_id}: {e}")
        return []

def delete_emergency_contact_from_firestore(user_id, contact_id):
    """
    Elimina un contacto de emergencia específico de un usuario.
    Retorna True si tiene éxito, False si falla.
    """
    try:
        contact_ref = db.collection('users').document(user_id).collection('emergencyContacts').document(contact_id)
        contact_ref.delete()
        print(f"Contacto de emergencia con ID {contact_id} eliminado para el usuario {user_id}.")
        return True
    except Exception as e:
        print(f"Error al eliminar contacto de emergencia {contact_id} para usuario {user_id}: {e}")
        return False

# ... Aquí irán más funciones para el violentómetro, evidencias, recursos, etc.
