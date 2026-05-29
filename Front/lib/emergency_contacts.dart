import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmergencyContactsScreen extends StatefulWidget {
  @override
  _EmergencyContactsScreenState createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<Map<String, dynamic>> contacts = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      // TODO: Reemplaza la URL y headers con los de tu backend y autenticación
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/user/contacts'),
        headers: {
          'Authorization': 'Bearer TU_TOKEN_AQUI',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          contacts = List<Map<String, dynamic>>.from(data['data'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error al cargar contactos';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de red';
        isLoading = false;
      });
    }
  }

  Future<void> addContactDialog() async {
    String name = '';
    String phone = '';
    String email = '';
    String relation = '';
    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar contacto'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nombre'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  onChanged: (v) => name = v,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Teléfono'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  onChanged: (v) => phone = v,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email (opcional)'),
                  onChanged: (v) => email = v,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Relación (opcional)'),
                  onChanged: (v) => relation = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await addContact(name, phone, email, relation);
                  Navigator.pop(context);
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addContact(String name, String phone, String email, String relation) async {
    try {
      // TODO: Reemplaza la URL y headers con los de tu backend y autenticación
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/user/contacts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer TU_TOKEN_AQUI',
        },
        body: json.encode({
          'name': name,
          'phone': phone,
          'email': email,
          'relation': relation,
        }),
      );
      if (response.statusCode == 201) {
        fetchContacts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar contacto')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red al agregar contacto')),
      );
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      // TODO: Reemplaza la URL y headers con los de tu backend y autenticación
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/user/contacts/$id'),
        headers: {
          'Authorization': 'Bearer TU_TOKEN_AQUI',
        },
      );
      if (response.statusCode == 200) {
        fetchContacts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar contacto')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red al eliminar contacto')),
      );
    }
  }

  Widget _buildSummaryCard() {
    final bool hasContacts = contacts.isNotEmpty;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasContacts ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasContacts ? Colors.green.withValues(alpha: 0.4) : Colors.orange.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(hasContacts ? Icons.verified_user : Icons.person_add_alt_1),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasContacts
                  ? 'Tienes ${contacts.length} contacto(s) registrado(s).'
                  : 'No tienes contactos registrados. Registra tu primer contacto.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contactos de Emergencia')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Column(
                  children: [
                    _buildSummaryCard(),
                    Expanded(
                      child: contacts.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.contacts, size: 56),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Registra tu primer contacto',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Agrega al menos una persona de confianza para emergencias.',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: addContactDialog,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Agregar primer contacto'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: contacts.length,
                              itemBuilder: (context, index) {
                                final contact = contacts[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    title: Text(contact['nombre_contacto'] ?? contact['name'] ?? ''),
                                    subtitle: Text(contact['telefono'] ?? contact['phone'] ?? ''),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => deleteContact(contact['id'] ?? ''),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: addContactDialog,
        child: Icon(Icons.add),
        tooltip: 'Agregar contacto',
      ),
    );
  }
}
