import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/escrito.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/services/utils.dart';
import 'package:tinyfal/src/views/principal/principal.dart';
import 'package:tinyfal/src/views/write/mail_disclaimer.dart'; // Import services for clipboard

class Write extends StatefulWidget {
  final ClientUser? clientUser;
  final Preferences? preferences;
  Escrito? escrito;

  Write({
    super.key,
    required this.clientUser,
    required this.preferences,
    this.escrito,
  }); // Default to false

  @override
  _Write createState() => _Write();
}

class _Write extends State<Write> {
  late final TextEditingController _textController;
  late final TextEditingController _titleController;
  final FocusNode _textFocusNode = FocusNode(); // Add FocusNode
  final FocusNode _titleFocusNode = FocusNode(); // Add FocusNode
  late String _visibility;
  late String _category;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.escrito?.text ?? '');
    _titleController = TextEditingController(text: widget.escrito?.title ?? '');
    _visibility = widget.escrito?.visibility ?? 'privado';
    _category = widget.escrito?.category ?? 'relato';
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose(); // Dispose title controller
    _textFocusNode.dispose();
    _titleFocusNode.dispose(); // Dispose FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            if (widget.escrito == null)
              MailDisclaimer(
                clientUser: widget.clientUser,
                preferences: widget.preferences,
              ),

            Padding(
              padding: const EdgeInsets.only(top: 20.0), // Add padding above
              child: TextField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 26,
                ),
                controller: _titleController, // Assign title controller
                focusNode: _titleFocusNode,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Título...',
                  hintStyle: TextStyle(
                    fontSize: 26,
                    color: Theme.of(context).colorScheme.primary,
                  ), // Set hint text color to white
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              controller: _textController,
              focusNode: _textFocusNode, // Assign FocusNode
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Aquí empieza tu historia...',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ), // Set hint text color to white
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                ClipboardData? data = await Clipboard.getData(
                  Clipboard.kTextPlain,
                );
                if (data != null) {
                  _textController.text += data.text!;
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.paste),
                  SizedBox(width: 10),
                  Text('Pegar'),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _textFocusNode.unfocus();
                _titleFocusNode.unfocus(); // Unfocus the TextField
              },
              child: Text('Dejar de editar'),
            ),
            SizedBox(height: 20),
            Text(
              '¿Quién quieres que lo vea?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
              ),
            ),
            Wrap(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: 'publico',
                      groupValue: _visibility,
                      onChanged: (value) {
                        setState(() {
                          _visibility = value!;
                        });
                      },
                    ),
                    Text(
                      'Público',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (widget.preferences?.isEscuelaEscritores ?? false)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: 'escueladeescritores',
                        groupValue: _visibility,
                        onChanged: (value) {
                          setState(() {
                            _visibility = value!;
                          });
                        },
                      ),
                      Text(
                        'Escuela de escritores',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: 'privado',
                      groupValue: _visibility,
                      onChanged: (value) {
                        setState(() {
                          _visibility = value!;
                        });
                      },
                    ),
                    Text(
                      'Privado',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            Wrap(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: 'Microrrelato',
                      groupValue: _category,
                      onChanged: (value) {
                        setState(() {
                          _category = value!;
                        });
                      },
                    ),
                    Text(
                      'Microrrelato',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: 'Capítulo',
                      groupValue: _category,
                      onChanged: (value) {
                        setState(() {
                          _category = value!;
                        });
                      },
                    ),
                    Text(
                      'Capitulo de novela',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<String>(
                      value: 'relato',
                      groupValue: _category,
                      onChanged: (value) {
                        setState(() {
                          _category = value!;
                        });
                      },
                    ),
                    Text(
                      'Relato',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isEmpty &&
                    _textController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Todavía no has escrito nada!'),
                      duration: Duration(
                        seconds: 1,
                      ), // Set duration to 2 seconds
                    ),
                  );
                } else {
                  if (widget.escrito != null) {
                    widget.escrito!.title = _titleController.text;
                    widget.escrito?.text = _textController.text;
                    widget.escrito?.visibility = _visibility;
                    widget.escrito?.category = _category;
                    widget.escrito!.uploadToFirestore();
                  } else {
                    final newEscrito = Escrito(
                      uid: generateCode(),
                      clientUser: widget.clientUser,
                      visibility: _visibility,
                      category: _category,
                      title: _titleController.text,
                      text: _textController.text,
                    );
                    newEscrito.uploadToFirestore();
                  }

                  Navigator.of(context).pop(); // Handle save action
                }
              },
              child: Text('Guardar'),
            ),
            SizedBox(height: 20), // Add spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(); // Discard changes and pop the navigator
              },
              child: Text('Volver sin guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
