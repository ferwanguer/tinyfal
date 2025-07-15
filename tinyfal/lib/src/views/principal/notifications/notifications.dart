import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/preferences.dart';

import 'package:provider/provider.dart';
import 'package:tinyfal/src/models/notification.dart';
import 'package:tinyfal/src/services/database.dart';

class Notifications extends StatelessWidget {
  final ClientUser? clientUser;
  final Preferences preferences;

  const Notifications({super.key, this.clientUser, required this.preferences});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Notificacion>>.value(
      value: getNotificacionsStream(clientUser!.uid),
      initialData: [],
      child: Consumer<List<Notificacion>>(
        builder: (context, notifications, child) {
          if (notifications.isEmpty) {
            return Center(child: Text('No notifications available'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                elevation: 0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(notification.body),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    //TODO fix this
                    // notifications[index]
                    //     .fetchEscrito(clientUser!.uid, notification.escritoId!)
                    //     .then((escrito) {
                    //       Navigator.of(context).push(
                    //         MaterialPageRoute(
                    //           builder: (context) => Write(
                    //             clientUser: clientUser,
                    //             escrito: escrito, //TODO FIX THIS
                    //             preferences: preferences,
                    //           ),
                    //         ),
                    //       );
                    //     });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
