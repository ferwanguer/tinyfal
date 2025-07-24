import 'package:cloud_firestore/cloud_firestore.dart';

class Preferences {
  // This object is the client user which should contains preferences and anything useful related to the client

  String? sender;
  bool notificationsEnabled;
  bool cpuNotificationsEnabled;
  bool ramNotificationsEnabled;
  double cpuThreshold;
  double ramThreshold;

  Preferences({
    this.sender,
    this.notificationsEnabled = true,
    this.cpuNotificationsEnabled = false,
    this.ramNotificationsEnabled = false,
    this.cpuThreshold = 10.0,
    this.ramThreshold = 85.0,
  });

  static Preferences? fromFirestore(DocumentSnapshot<Object?> doc) {
    if (!doc.exists) {
      return null;
    }
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String? sender;
    try {
      sender = data['email'] as String?;
    } catch (e) {
      sender = null;
    }

    bool notificationsEnabled = data['notificationsEnabled'] ?? true;
    bool cpuNotificationsEnabled = data['cpuNotificationsEnabled'] ?? false;
    bool ramNotificationsEnabled = data['ramNotificationsEnabled'] ?? false;
    double cpuThreshold = (data['cpuThreshold'] ?? 10.0).toDouble();
    double ramThreshold = (data['ramThreshold'] ?? 85.0).toDouble();

    return Preferences(
      sender: sender,
      notificationsEnabled: notificationsEnabled,
      cpuNotificationsEnabled: cpuNotificationsEnabled,
      ramNotificationsEnabled: ramNotificationsEnabled,
      cpuThreshold: cpuThreshold,
      ramThreshold: ramThreshold,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'cpuNotificationsEnabled': cpuNotificationsEnabled,
      'ramNotificationsEnabled': ramNotificationsEnabled,
      'cpuThreshold': cpuThreshold,
      'ramThreshold': ramThreshold,
    };
  }
}
