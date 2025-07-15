import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/services/database.dart';

class Status {
  final Map<String, dynamic> _data;

  Status(this._data);

  /// Create Status from JSON map
  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(Map<String, dynamic>.from(json));
  }

  /// Create Status from raw JSON without knowing the structure
  factory Status.fromDynamicJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return Status.fromJson(json);
    } else if (json is Map) {
      // Handle other map types
      return Status(Map<String, dynamic>.from(json));
    } else {
      throw ArgumentError('JSON must be a Map structure');
    }
  }

  /// Get any property by key
  dynamic operator [](String key) => _data[key];

  /// Set any property by key
  void operator []=(String key, dynamic value) => _data[key] = value;

  /// Check if a key exists
  bool containsKey(String key) => _data.containsKey(key);

  /// Get all keys
  Iterable<String> get keys => _data.keys;

  /// Get all values
  Iterable<dynamic> get values => _data.values;

  /// Check if empty
  bool get isEmpty => _data.isEmpty;

  /// Check if not empty
  bool get isNotEmpty => _data.isNotEmpty;

  /// Get raw data
  Map<String, dynamic> get data => Map<String, dynamic>.from(_data);

  /// Convert to JSON
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(_data);

  /// Get a typed value with default fallback
  T? get<T>(String key, [T? defaultValue]) {
    final value = _data[key];
    if (value is T) return value;
    return defaultValue;
  }

  /// Get a nested Status object
  Status? getStatus(String key) {
    final value = _data[key];
    if (value is Map<String, dynamic>) {
      return Status(value);
    }
    return null;
  }

  /// Get a list of Status objects
  List<Status>? getStatusList(String key) {
    final value = _data[key];
    if (value is List) {
      return value
          .where((item) => item is Map<String, dynamic>)
          .map((item) => Status(item as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  @override
  String toString() => _data.toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Status) return false;
    return _data.toString() == other._data.toString();
  }

  @override
  int get hashCode => _data.hashCode;
}

class Resource {
  String? uid;
  String? title;
  ClientUser? clientUser;
  Status? status;
  String? token;

  Resource({
    this.title,
    required this.uid,
    required this.clientUser,
    this.status,
    this.token,
  });

  Future<void> uploadToFirestore() async {
    await updateResource(clientUser!.uid, uid!, this);
  }

  Future<void> deleteFromFirestore() async {
    await deleteResource(clientUser!.uid, uid!);
  }

  Future<void> updateStatus(Status newStatus) async {
    status = newStatus;
    await uploadToFirestore();
  }

  /// Generate a random token (8 characters)
  String _generateRandomToken() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Create a new random token
  Future<void> createToken() async {
    token = _generateRandomToken();
    await uploadToFirestore();
  }

  /// Regenerate token (delete old and create new)
  Future<void> regenerateToken() async {
    token = _generateRandomToken();
    await uploadToFirestore();
  }

  factory Resource.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Resource(
      uid: doc.id,
      title: data['title'],
      clientUser: ClientUser(uid: data['authorId']),
      status: data['status'] != null
          ? Status.fromDynamicJson(data['status'])
          : null,
      token: data['token'],
    );
  }
}
