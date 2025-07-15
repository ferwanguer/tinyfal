import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/services/database.dart';
import 'package:tinyfal/src/models/resource.dart';
import 'package:tinyfal/src/views/principal/home/resource_tile.dart';

class Home extends StatefulWidget {
  final ClientUser? clientUser;
  final Preferences? preferences;

  const Home({super.key, this.clientUser, this.preferences});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    //print('🔵 INIT: Setting up timer...');

    // Set up timer to refresh UI every 2 minutes to update freshness indicators
    _refreshTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      //print("🟢 TIMER: Refreshing resources... ${DateTime.now()}");
      if (mounted) {
        //print("🟡 TIMER: Calling setState");
        setState(() {
          // This will trigger a rebuild of all resource tiles
          // Freshness indicators will automatically update
        });
      } else {
        //print("🔴 TIMER: Widget not mounted, canceling");
        timer.cancel();
      }
    });

    //print('🔵 INIT: Timer setup complete');
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print('🟠 BUILD: Home widget building at ${DateTime.now()}');
    return Scaffold(
      body: StreamBuilder<List<Resource?>>(
        stream: getResourcesStream(widget.clientUser!.uid),
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
                  preferences: widget.preferences!,
                  clientUser: widget.clientUser,
                );
              },
            );
          }
        },
      ),
    );
  }
}
