import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/views/principal/home/home.dart';
import 'package:tinyfal/src/views/principal/notifications/notifications.dart';
import 'package:tinyfal/src/views/principal/profile/profile.dart';
import 'package:tinyfal/src/views/principal/thesearch/thesearch.dart';
import 'package:tinyfal/src/views/write/write.dart';
import 'package:tinyfal/src/services/database.dart'; // Import the database service
import 'package:tinyfal/src/models/preferences.dart'; // Import the Preferences model
import 'package:provider/provider.dart'; // Import Provider package

import 'package:tinyfal/src/views/settings/settings.dart';

// SET UP HERE THE PREFERENCES STREAM
/// Displays a list of SampleItems.
class Principal extends StatefulWidget {
  const Principal({super.key, required this.clientUser});

  static const routeName = '/';

  final ClientUser? clientUser;

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Initialize PageController
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<Preferences?>.value(
      value: getPreferencesStream(widget.clientUser!.uid),
      initialData: null,
      child: Consumer<Preferences?>(
        builder: (context, preferences, child) {
          if (preferences == null) {
            return Center(child: CircularProgressIndicator());
          }
          return Scaffold(
            appBar: AppBar(
              title: Text("Literatos"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Settings(clientUser: widget.clientUser),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                Home(clientUser: widget.clientUser, preferences: preferences),
                TheSearch(
                  clientUser: widget.clientUser,
                  preferences: preferences,
                ),
                Notifications(
                  clientUser: widget.clientUser,
                  preferences: preferences,
                ),
                Profile(
                  clientUser: widget.clientUser,
                  preferences: preferences,
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'Notifications',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Theme.of(
                context,
              ).colorScheme.primaryFixedDim, // Set your desired color here
              unselectedItemColor: Theme.of(
                context,
              ).colorScheme.primaryFixedDim,
              onTap: _onItemTapped,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (preferences.username == null ||
                    preferences.username!.isEmpty ||
                    preferences.description == null ||
                    preferences.description!.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Atención'),
                        content: Text(
                          'Dinos como te llamas antes de empezar a escribir!',
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Ir a ajustes'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Settings(clientUser: widget.clientUser),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Write(
                        clientUser: widget.clientUser,
                        preferences: preferences,
                      ),
                    ),
                  );
                }
              },
              backgroundColor: const Color.fromARGB(255, 119, 200, 238),
              child: FaIcon(
                FontAwesomeIcons.penNib,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          );
        },
      ),
    );
  }
}
