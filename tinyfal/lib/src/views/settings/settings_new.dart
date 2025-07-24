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
  Preferences? currentPreferences;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    if (widget.clientUser != null) {
      final prefs = await getPreferences(widget.clientUser!.uid);
      setState(() {
        currentPreferences = prefs;
        isLoading = false;
      });
    }
  }

  Future<void> _updatePreference(String field, dynamic value) async {
    if (widget.clientUser != null) {
      await updateUserPreferenceField(widget.clientUser!.uid, field, value);
      // Update local state immediately for better UX
      setState(() {
        if (currentPreferences != null) {
          switch (field) {
            case 'notificationsEnabled':
              currentPreferences = Preferences(
                sender: currentPreferences!.sender,
                notificationsEnabled: value as bool,
                cpuNotificationsEnabled:
                    currentPreferences!.cpuNotificationsEnabled,
                ramNotificationsEnabled:
                    currentPreferences!.ramNotificationsEnabled,
                cpuThreshold: currentPreferences!.cpuThreshold,
                ramThreshold: currentPreferences!.ramThreshold,
              );
              break;
            case 'cpuNotificationsEnabled':
              currentPreferences = Preferences(
                sender: currentPreferences!.sender,
                notificationsEnabled: currentPreferences!.notificationsEnabled,
                cpuNotificationsEnabled: value as bool,
                ramNotificationsEnabled:
                    currentPreferences!.ramNotificationsEnabled,
                cpuThreshold: currentPreferences!.cpuThreshold,
                ramThreshold: currentPreferences!.ramThreshold,
              );
              break;
            case 'ramNotificationsEnabled':
              currentPreferences = Preferences(
                sender: currentPreferences!.sender,
                notificationsEnabled: currentPreferences!.notificationsEnabled,
                cpuNotificationsEnabled:
                    currentPreferences!.cpuNotificationsEnabled,
                ramNotificationsEnabled: value as bool,
                cpuThreshold: currentPreferences!.cpuThreshold,
                ramThreshold: currentPreferences!.ramThreshold,
              );
              break;
            case 'cpuThreshold':
              currentPreferences = Preferences(
                sender: currentPreferences!.sender,
                notificationsEnabled: currentPreferences!.notificationsEnabled,
                cpuNotificationsEnabled:
                    currentPreferences!.cpuNotificationsEnabled,
                ramNotificationsEnabled:
                    currentPreferences!.ramNotificationsEnabled,
                cpuThreshold: value as double,
                ramThreshold: currentPreferences!.ramThreshold,
              );
              break;
            case 'ramThreshold':
              currentPreferences = Preferences(
                sender: currentPreferences!.sender,
                notificationsEnabled: currentPreferences!.notificationsEnabled,
                cpuNotificationsEnabled:
                    currentPreferences!.cpuNotificationsEnabled,
                ramNotificationsEnabled:
                    currentPreferences!.ramNotificationsEnabled,
                cpuThreshold: currentPreferences!.cpuThreshold,
                ramThreshold: value as double,
              );
              break;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(title: Text('Settings')),
      body: widget.clientUser == null
          ? Center(child: Text('No user found'))
          : isLoading
          ? Center(child: CircularProgressIndicator())
          : currentPreferences == null
          ? Center(child: Text('No preferences found'))
          : Center(
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
                      currentPreferences?.sender ?? "",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Notification Settings Section
                  Text(
                    'Notification Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // General Notifications Toggle
                          SwitchListTile(
                            title: Text('Enable Notifications'),
                            subtitle: Text('Receive push notifications'),
                            value:
                                currentPreferences?.notificationsEnabled ??
                                true,
                            onChanged: (bool value) {
                              _updatePreference('notificationsEnabled', value);
                            },
                          ),
                          Divider(),

                          // CPU Notifications
                          SwitchListTile(
                            title: Text('CPU Alerts'),
                            subtitle: Text('Alert when CPU available is low'),
                            value:
                                currentPreferences?.cpuNotificationsEnabled ??
                                false,
                            onChanged:
                                (currentPreferences?.notificationsEnabled ??
                                    true)
                                ? (bool value) {
                                    _updatePreference(
                                      'cpuNotificationsEnabled',
                                      value,
                                    );
                                  }
                                : null,
                          ),

                          // CPU Threshold Slider
                          if (currentPreferences?.cpuNotificationsEnabled ??
                              false)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CPU Threshold: ${(currentPreferences?.cpuThreshold ?? 10.0).round()}%',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Slider(
                                    value:
                                        currentPreferences?.cpuThreshold ??
                                        10.0,
                                    min: 1.0,
                                    max: 50.0,
                                    divisions: 49,
                                    label:
                                        '${(currentPreferences?.cpuThreshold ?? 10.0).round()}%',
                                    onChanged: (double value) {
                                      _updatePreference('cpuThreshold', value);
                                    },
                                  ),
                                  Text(
                                    'Alert when CPU available drops below this threshold',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          Divider(),

                          // RAM Notifications
                          SwitchListTile(
                            title: Text('RAM Alerts'),
                            subtitle: Text('Alert when RAM usage is high'),
                            value:
                                currentPreferences?.ramNotificationsEnabled ??
                                false,
                            onChanged:
                                (currentPreferences?.notificationsEnabled ??
                                    true)
                                ? (bool value) {
                                    _updatePreference(
                                      'ramNotificationsEnabled',
                                      value,
                                    );
                                  }
                                : null,
                          ),

                          // RAM Threshold Slider
                          if (currentPreferences?.ramNotificationsEnabled ??
                              false)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RAM Threshold: ${(currentPreferences?.ramThreshold ?? 85.0).round()}%',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Slider(
                                    value:
                                        currentPreferences?.ramThreshold ??
                                        85.0,
                                    min: 50.0,
                                    max: 95.0,
                                    divisions: 45,
                                    label:
                                        '${(currentPreferences?.ramThreshold ?? 85.0).round()}%',
                                    onChanged: (double value) {
                                      _updatePreference('ramThreshold', value);
                                    },
                                  ),
                                  Text(
                                    'Alert when RAM usage exceeds this threshold',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
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
                                  content: Text('Account deleted successfully'),
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
                                  content: Text('Error al eliminar la cuenta'),
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
            ),
    );
  }
}
