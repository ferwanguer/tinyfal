import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/services/database.dart';

class Status {
  final List<Map<String, dynamic>> _data;

  Status(this._data);

  /// Create Status from a list of JSON maps
  factory Status.fromJsonList(List<dynamic> jsonList) {
    final dataList = jsonList
        .where((item) => item is Map)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    return Status(dataList);
  }

  /// Get the length of the list
  int get length => _data.length;

  /// Check if empty
  bool get isEmpty => _data.isEmpty;

  /// Check if not empty
  bool get isNotEmpty => _data.isNotEmpty;

  /// Get raw data as list
  List<Map<String, dynamic>> get data => List<Map<String, dynamic>>.from(_data);

  /// Get all maps with a given 'name' attribute
  List<Map<String, dynamic>> getByName(String name) {
    return _data.where((item) => item['name'] == name).toList();
  }

  /// RAM MEMORY
  Map<String, dynamic>? get mem {
    final memList = getByName('mem');
    return memList.isNotEmpty ? memList.first : null;
  }

  /// Get used memory percentage (rounded up, no decimal places)
  int? get usedMemoryPercent {
    final memData = mem;
    if (memData == null) return null;

    final fields = memData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final availablePercent = fields['available_percent'];
    if (availablePercent == null) return null;

    final available = (availablePercent is num)
        ? availablePercent.toDouble()
        : null;
    if (available == null) return null;

    final used = 100.0 - available;
    return used.ceil();
  }

  int? get availableMemoryPercent {
    final memData = mem;
    if (memData == null) return null;

    final fields = memData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final availablePercent = fields['available_percent'];
    if (availablePercent == null) return null;

    return (availablePercent is num)
        ? availablePercent.toDouble().ceil()
        : null;
  }
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
    this.status,
    this.clientUser,
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
    const chars = '0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        15, // Generate 15 characters
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Create a new random token
  Future<void> createToken() async {
    token = _generateRandomToken();
    await updateResourceToken(clientUser!.uid, uid!, token!);
  }

  /// Regenerate token (delete old and create new)
  Future<void> regenerateToken() async {
    token = _generateRandomToken();
    await updateResourceToken(clientUser!.uid, uid!, token!);
  }

  factory Resource.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Resource(
      uid: doc.id,
      title: data['title'],
      status: data['metrics'] != null
          ? Status.fromJsonList(data['metrics'])
          : null,
      token: data['token'],
    );
  }
}
