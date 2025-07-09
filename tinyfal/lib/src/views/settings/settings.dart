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
  late TextEditingController _descriptionController;
  late TextEditingController _webController;
  late TextEditingController _usernameController;
  late TextEditingController _textFontSizeController;
  TextEditingController _codeController = TextEditingController();
  bool _isUpdated = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _webController = TextEditingController();
    _usernameController = TextEditingController();
    _textFontSizeController = TextEditingController();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _webController.dispose();
    _usernameController.dispose();
    _textFontSizeController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _updatePreferences() {
    if (widget.clientUser != null) {
      updateUserPreferenceField(
        widget.clientUser!.uid,
        'description',
        _descriptionController.text,
      );
      updateUserPreferenceField(
        widget.clientUser!.uid,
        'web',
        _webController.text,
      );
      updateUserPreferenceField(
        widget.clientUser!.uid,
        'username',
        _usernameController.text,
      );
      updateUserPreferenceField(
        widget.clientUser!.uid,
        'textFontSize',
        double.parse(_textFontSizeController.text),
      );
      updateUserPreferenceField(
        widget.clientUser!.uid,
        'code',
        _codeController.text,
      );
      setState(() {
        _isUpdated = true;
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

                _descriptionController.text = preferences?.description ?? '';
                _webController.text = preferences?.web ?? '';
                _usernameController.text = preferences?.username ?? '';
                _textFontSizeController.text =
                    preferences?.textFontSize.toString() ?? '14.0';
                _codeController.text = '';

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
                      Divider(),
                      ListTile(
                        leading: Text('Nombre', style: TextStyle(fontSize: 16)),
                        subtitle: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          child: TextField(
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            controller: _usernameController,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: '¿Cómo te llamas?',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Text(
                          'Algo sobre tí',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          child: TextField(
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            controller: _descriptionController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Cuéntanos algo sobre ti',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Text('Web?', style: TextStyle(fontSize: 16)),
                        subtitle: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          child: TextField(
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            controller: _webController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Si la tienes',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Text(
                          'Tamaño de fuente',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          child: TextField(
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            controller: _textFontSizeController,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Enter text font size',
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        leading: Text('Código', style: TextStyle(fontSize: 16)),
                        subtitle: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.9,
                          ),
                          child: TextField(
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            controller: _codeController,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Introduce tu código',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Escuela Escritores'),
                        trailing: preferences!.isEscuelaEscritores
                            ? Icon(
                                Icons.verified,
                                color: Color.fromARGB(255, 235, 145, 53),
                              )
                            : Icon(
                                Icons.radio_button_unchecked,
                                color: Colors.amberAccent,
                              ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updatePreferences,
                        style: ElevatedButton.styleFrom(
                          shadowColor: Theme.of(context).colorScheme.onPrimary,
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.9,
                            50,
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primaryFixed,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Actualizar',
                          style: TextStyle(
                            color: _isUpdated ? Colors.green : Colors.blue,
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
