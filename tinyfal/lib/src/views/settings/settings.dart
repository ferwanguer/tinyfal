import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/services/auth.dart';
import 'package:tinyfal/src/services/database.dart';

class Settings extends StatefulWidget {
  final ClientUser? clientUser;

  const Settings({super.key, required this.clientUser});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(title: Text('Settings')),
      body: widget.clientUser == null
          ? Center(child: Text('No user found'))
          : FutureBuilder<Preferences?>(
              future: getPreferences(widget.clientUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return Center(child: Text('No preferences found'));
                }

                Preferences? preferences = snapshot.data;

                return Center(
                  child: ListView(
                    padding: EdgeInsets.all(16.0),
                    children: <Widget>[
                      ListTile(
                        leading: Text("ID"),
                        subtitle: Text(widget.clientUser?.uid ?? ""),
                        trailing: IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: widget.clientUser?.uid ?? ""),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ID copied to clipboard')),
                            );
                          },
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Text('Email', style: TextStyle(fontSize: 16)),
                        title: Text(
                          preferences?.sender ?? "",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          signOut();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          shadowColor: Theme.of(context).colorScheme.onPrimary,
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.9,
                            50,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cerrar sesión',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          // Show confirmation dialog
                          bool? confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Eliminar cuenta'),
                                content: Text(
                                  '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Cancelar'),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true) {
                            try {
                              bool success = await deleteAccount();
                              if (success) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Account deleted successfully',
                                      ),
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error, contact support@tinyfal.com ',
                                      ),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                if (e is FirebaseAuthException &&
                                    e.code == 'requires-recent-login') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Necesitas iniciar sesión nuevamente para eliminar tu cuenta',
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error al eliminar la cuenta',
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shadowColor: Theme.of(context).colorScheme.onPrimary,
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.9,
                            50,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Eliminar cuenta',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Developed and deployed by FWG © 2022",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
