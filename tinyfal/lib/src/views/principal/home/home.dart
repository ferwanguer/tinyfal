import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/services/database.dart';
import 'package:tinyfal/src/models/resource.dart';
import 'package:tinyfal/src/views/principal/home/resource_tile.dart';

class Home extends StatelessWidget {
  final ClientUser? clientUser;
  final Preferences? preferences;

  const Home({super.key, this.clientUser, this.preferences});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Resource?>>(
        stream: getResourcesStream(clientUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Create a resource to see it here.'));
          } else {
            final resources = snapshot.data!;

            return ListView.builder(
              itemCount: resources.length,
              itemBuilder: (context, index) {
                final resource = resources[index];
                return ResourceTile(
                  resource: resource!,
                  preferences: preferences!,
                  clientUser: clientUser,
                );
              },
            );
          }
        },
      ),
    );
  }
}
