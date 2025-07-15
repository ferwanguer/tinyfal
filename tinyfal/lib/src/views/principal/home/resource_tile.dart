import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/resource.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/services/database.dart';
import 'package:tinyfal/src/services/utils.dart';
import 'package:tinyfal/src/views/principal/read/read.dart';
import 'package:provider/provider.dart';

class ResourceTile extends StatelessWidget {
  final Resource resource;
  final ClientUser? clientUser;
  final Preferences? preferences;

  const ResourceTile({
    super.key,
    required this.resource,
    required this.preferences,
    required this.clientUser,
  });

  @override
  Widget build(BuildContext context) {
    if (preferences == null) {
      return CircularProgressIndicator();
    }

    return Column(
      children: [
        ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    Read(escrito: resource, preferences: preferences),
              ),
            );
          },
          contentPadding: EdgeInsets.only(
            left: 10,
            right: 10,
          ), // Removes default padding
          title: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Text(
                  resource.title ?? "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 19,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          subtitle: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    resource.status?['authorName'] ??
                        resource.clientUser?.uid ??
                        "",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  if (resource.status?['isEscuelaEscritores'] == true)
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Icon(
                        Icons.verified,
                        color: Color.fromARGB(255, 235, 145, 53),
                        size: 13,
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  resource.status?['text'] ?? "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                  style: TextStyle(fontSize: preferences!.textFontSize),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${calculateReadingTime(resource.status?['text'] ?? '')} min",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              Text(
                resource.status?['category'] ?? "",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Divider(
            color: Theme.of(context).colorScheme.tertiary,
            thickness: 0.3,
          ),
        ),
      ],
    );
  }
}
