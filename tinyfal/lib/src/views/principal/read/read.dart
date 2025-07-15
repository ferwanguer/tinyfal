import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/resource.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:provider/provider.dart';
import 'package:tinyfal/src/services/database.dart'; // Import the database service

//TODO REUNIFICAR LOS STREAMPROVIDERS EN EL PADRE. ES POSIBLE. SIENDO EL PADRE HOME
class Read extends StatefulWidget {
  final Escrito escrito;
  final Preferences? preferences;
  const Read({super.key, required this.escrito, required this.preferences});

  @override
  State<Read> createState() => _ReadState();
}

class _ReadState extends State<Read> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 500) {
            Navigator.of(context).pop();
          }
        },
        child: StreamProvider<Preferences?>.value(
          value: getPreferencesStream(
            widget.escrito.clientUser!.uid,
          ), // Get preferences stream
          initialData: null,
          child: Consumer<Preferences?>(
            builder: (context, escritoPreferences, child) {
              if (escritoPreferences == null) {
                return CircularProgressIndicator();
              }
              return Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16, top: 15),
                child: ListView.builder(
                  itemCount: widget.escrito.comments.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10.0,
                              bottom: 20,
                            ),
                            child: Center(
                              child: Text(
                                widget.escrito.title ?? "",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10.0,
                              bottom: 20,
                            ),
                            child: Center(
                              child: Text(
                                widget.escrito.text ?? "",
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize:
                                      Provider.of<Preferences?>(
                                        context,
                                      )?.textFontSize ??
                                      12,
                                  height: 1.8, // Added line height
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10.0,
                              bottom: 10,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  escritoPreferences.username ?? "",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      final comment = widget.escrito.comments[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Center(
                          child: Text(
                            comment.text,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
