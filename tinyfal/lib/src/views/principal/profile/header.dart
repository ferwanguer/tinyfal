import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/preferences.dart';

class Header extends StatelessWidget {
  final ClientUser? clientUser;
  final Preferences preferences;

  const Header({
    super.key,
    required this.clientUser,
    required this.preferences,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (clientUser?.photoUrl != null && !kIsWeb)
          CachedNetworkImage(
            imageUrl: clientUser!.photoUrl!,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            imageBuilder: (context, imageProvider) => Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 20),
          child: Center(
            child: Text(
              preferences.username ?? "",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 30,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Center(
            child: Text(
              preferences.description ?? "",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
