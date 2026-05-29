# firebase_config.py
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import os

# IMPORTANTE: Reemplaza con el nombre EXACTO de tu archivo JSON.
# Asegúrate de que el archivo JSON esté junto a este script o en la raíz del proyecto.
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SERVICE_ACCOUNT_KEY_PATH = os.path.join(BASE_DIR, 'LlaveFIRESTORE.json')

# Verifica si el archivo de credenciales existe
if not os.path.exists(SERVICE_ACCOUNT_KEY_PATH):
    print(f"Error: El archivo de credenciales '{SERVICE_ACCOUNT_KEY_PATH}' no se encontró.")
    print("Asegúrate de haber descargado el archivo JSON de la cuenta de servicio y de haberlo colocado en la ruta correcta.")
    # Considera elevar una excepción si esto es un error crítico para tu aplicación
    # raise FileNotFoundError(f"Archivo de credenciales no encontrado en {SERVICE_ACCOUNT_KEY_PATH}")
    exit(1) # Termina la ejecución si el archivo no se encuentra

cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
try:
    firebase_admin.initialize_app(cred)
    print("Firebase Admin SDK inicializado exitosamente.")
except ValueError as e:
    # Esto ocurre si initialize_app se llama múltiples veces en algunos entornos
    if "The default Firebase app already exists" in str(e):
        print("Firebase Admin SDK ya inicializado (en un entorno de recarga de Flask, por ejemplo).")
    else:
        raise e

# Exporta el cliente de Firestore para que otros módulos lo puedan usar
db = firestore.client()
print("Cloud Firestore cliente creado.")
