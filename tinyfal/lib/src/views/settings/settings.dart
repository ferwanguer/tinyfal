import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
