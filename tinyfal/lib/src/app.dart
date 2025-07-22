import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/services/auth.dart';
import 'package:tinyfal/src/views/login/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/principal/principal.dart';
import 'package:tinyfal/src/shared/color_schemes.dart';
import 'package:flutter/animation.dart';

import 'package:provider/provider.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<ClientUser?>.value(
      initialData: null,
      value: user,
      child: Consumer<ClientUser?>(
        builder: (context, clientUser, child) {
          return MaterialApp(
            // Providing a restorationScopeId allows the Navigator built by the
            // MaterialApp to restore the navigation stack when a user leaves and
            // returns to the app after it has been killed while running in the
            // background.
            restorationScopeId: 'app',

            // Remove the debug banner
            debugShowCheckedModeBanner: false,

            // Provide the generated AppLocalizations to the MaterialApp. This
            // allows descendant Widgets to display the correct translations
            // depending on the user's locale.
            supportedLocales: const [
              Locale('en', ''), // English, no country code
            ],

            // Use AppLocalizations to configure the correct application title
            // depending on the user's locale.
            //
            // The appTitle is defined in .arb files found in the localization
            // directory.

            // Define a light and dark color theme. Then, read the user's
            // preferred ThemeMode (light, dark, or system default) from the
            // SettingsController to display the correct theme.
            theme: ThemeData(
              colorScheme: lightGreyColorScheme,
              textTheme: GoogleFonts.loraTextTheme(),
            ),
            darkTheme: ThemeData(
              colorScheme: darkGreyColorScheme,
              textTheme: GoogleFonts.loraTextTheme(),
            ),
            themeMode: ThemeMode.light,

            // Determine the home screen based on the user authentication state. Inside an animation switcher
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: clientUser == null
                  ? const LoginScreen(key: ValueKey('LoginScreen'))
                  : Principal(
                      key: const ValueKey('Principal'),
                      clientUser: clientUser,
                    ),
            ),
          );
        },
      ),
    );
  }
}
