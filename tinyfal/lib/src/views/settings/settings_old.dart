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
      // Reload preferences to get updated values
      await _loadPreferences();
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
                          _localPreferences?.sender ?? "",
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
                                value: _localPreferences?.notificationsEnabled ?? true,
                                onChanged: (bool value) async {
                                  setState(() {
                                    _localPreferences = Preferences(
                                      sender: _localPreferences?.sender,
                                      notificationsEnabled: value,
                                      cpuNotificationsEnabled: _localPreferences?.cpuNotificationsEnabled ?? false,
                                      ramNotificationsEnabled: _localPreferences?.ramNotificationsEnabled ?? false,
                                      cpuThreshold: _localPreferences?.cpuThreshold ?? 10.0,
                                      ramThreshold: _localPreferences?.ramThreshold ?? 85.0,
                                    );
                                  });
                                  await updateUserPreferenceField(
                                    widget.clientUser!.uid,
                                    'notificationsEnabled',
                                    value,
                                  );
                                },
                              ),
                              Divider(),

                              // CPU Notifications
                              SwitchListTile(
                                title: Text('CPU Alerts'),
                                subtitle: Text(
                                  'Alert when CPU available is low',
                                ),
                                value:
                                    preferences?.cpuNotificationsEnabled ??
                                    false,
                                onChanged:
                                    (preferences?.notificationsEnabled ?? true)
                                    ? (bool value) async {
                                        await updateUserPreferenceField(
                                          widget.clientUser!.uid,
                                          'cpuNotificationsEnabled',
                                          value,
                                        );
                                      }
                                    : null,
                              ),

                              // CPU Threshold Slider
                              if (preferences?.cpuNotificationsEnabled ?? false)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'CPU Threshold: ${((_localCpuThreshold ?? preferences?.cpuThreshold) ?? 10.0).round()}%',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          if (_isSavingCpu)
                                            SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Slider(
                                        value: (_localCpuThreshold ?? preferences?.cpuThreshold) ?? 10.0,
                                        min: 1.0,
                                        max: 50.0,
                                        divisions: 49,
                                        label:
                                            '${((_localCpuThreshold ?? preferences?.cpuThreshold) ?? 10.0).round()}%',
                                        onChanged: (double value) {
                                          // Haptic feedback for better UX
                                          HapticFeedback.selectionClick();
                                          
                                          // Update local state immediately for visual feedback
                                          setState(() {
                                            _localCpuThreshold = value;
                                          });
                                          
                                          // Cancel previous timer
                                          _cpuSliderDebounce?.cancel();
                                          
                                          // Start new timer to update database after user stops sliding
                                          _cpuSliderDebounce = Timer(
                                            Duration(milliseconds: 500),
                                            () async {
                                              setState(() {
                                                _isSavingCpu = true;
                                              });
                                              
                                              await updateUserPreferenceField(
                                                widget.clientUser!.uid,
                                                'cpuThreshold',
                                                value,
                                              );
                                              
                                              // Clear local state after database update
                                              if (mounted) {
                                                setState(() {
                                                  _localCpuThreshold = null;
                                                  _isSavingCpu = false;
                                                });
                                              }
                                            },
                                          );
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
                                    preferences?.ramNotificationsEnabled ??
                                    false,
                                onChanged:
                                    (preferences?.notificationsEnabled ?? true)
                                    ? (bool value) async {
                                        await updateUserPreferenceField(
                                          widget.clientUser!.uid,
                                          'ramNotificationsEnabled',
                                          value,
                                        );
                                      }
                                    : null,
                              ),

                              // RAM Threshold Slider
                              if (preferences?.ramNotificationsEnabled ?? false)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'RAM Threshold: ${((_localRamThreshold ?? preferences?.ramThreshold) ?? 85.0).round()}%',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          if (_isSavingRam)
                                            SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Slider(
                                        value: (_localRamThreshold ?? preferences?.ramThreshold) ?? 85.0,
                                        min: 50.0,
                                        max: 95.0,
                                        divisions: 45,
                                        label:
                                            '${((_localRamThreshold ?? preferences?.ramThreshold) ?? 85.0).round()}%',
                                        onChanged: (double value) {
                                          // Haptic feedback for better UX
                                          HapticFeedback.selectionClick();
                                          
                                          // Update local state immediately for visual feedback
                                          setState(() {
                                            _localRamThreshold = value;
                                          });
                                          
                                          // Cancel previous timer
                                          _ramSliderDebounce?.cancel();
                                          
                                          // Start new timer to update database after user stops sliding
                                          _ramSliderDebounce = Timer(
                                            Duration(milliseconds: 500),
                                            () async {
                                              setState(() {
                                                _isSavingRam = true;
                                              });
                                              
                                              await updateUserPreferenceField(
                                                widget.clientUser!.uid,
                                                'ramThreshold',
                                                value,
                                              );
                                              
                                              // Clear local state after database update
                                              if (mounted) {
                                                setState(() {
                                                  _localRamThreshold = null;
                                                  _isSavingRam = false;
                                                });
                                              }
                                            },
                                          );
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
