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

    final usedPercent = fields['used_percent'];
    if (usedPercent == null) return null;

    return (usedPercent is num) ? usedPercent.toDouble().ceil() : null;
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

  /// Get buffered memory in MB (rounded up)
  int? get bufferedMemoryMB {
    final memData = mem;
    if (memData == null) return null;

    final fields = memData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final buffered = fields['buffered'];
    if (buffered == null) return null;

    return (buffered is num)
        ? (buffered.toDouble() / 1024 / 1024).ceil()
        : null;
  }

  /// Get cached memory in MB (rounded up)
  int? get cachedMemoryMB {
    final memData = mem;
    if (memData == null) return null;

    final fields = memData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final cached = fields['cached'];
    if (cached == null) return null;

    return (cached is num) ? (cached.toDouble() / 1024 / 1024).ceil() : null;
  }

  /// SWAP MEMORY
  Map<String, dynamic>? get swap {
    final swapList = getByName('swap');
    return swapList.isNotEmpty ? swapList.first : null;
  }

  /// Get used swap percentage (rounded up, no decimal places)
  int? get usedSwapPercent {
    final swapData = swap;
    if (swapData == null) return null;

    final fields = swapData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final usedPercent = fields['used_percent'];
    if (usedPercent == null) return null;

    return (usedPercent is num) ? usedPercent.toDouble().ceil() : null;
  }

  /// CPU DATA
  Map<String, dynamic>? get cpuTotal {
    final cpuList = getByName('cpu');
    // Look for the cpu-total entry specifically
    for (final cpu in cpuList) {
      final tags = cpu['tags'] as Map<String, dynamic>?;
      if (tags != null && tags['cpu'] == 'cpu-total') {
        return cpu;
      }
    }
    return null;
  }

  /// Get all CPU cores data
  List<Map<String, dynamic>> get cpuCores {
    final cpuList = getByName('cpu');
    // Filter out cpu-total, return individual cores
    return cpuList.where((cpu) {
      final tags = cpu['tags'] as Map<String, dynamic>?;
      return tags != null && tags['cpu'] != 'cpu-total';
    }).toList();
  }

  /// Get total CPU usage percentage (rounded up, no decimal places)
  /// Calculated as: 100 - idle_usage
  int? get cpuUsagePercent {
    final cpuData = cpuTotal;
    if (cpuData == null) return null;

    final fields = cpuData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final idleUsage = fields['usage_idle'];
    if (idleUsage == null) return null;

    if (idleUsage is num) {
      final usedPercent = 100.0 - idleUsage.toDouble();
      final result = usedPercent.ceil().clamp(0, 100);

      // Handle anomalous 0% readings that can occur after reconnection
      // If we get 0% but have recent data, it might be a measurement artifact
      if (result == 0) {
        final timestamp = lastUpdated;
        if (timestamp != null) {
          final minutesSinceUpdate = DateTime.now()
              .difference(timestamp)
              .inMinutes;
          // If data is very fresh (< 1 minute) but shows 0%, it's likely a restart artifact
          if (minutesSinceUpdate < 1) {
            // Return null to indicate "calculating..." rather than showing misleading 0%
            return null;
          }
        }
      }

      return result;
    }
    return null;
  }

  /// Get CPU user usage percentage
  int? get cpuUserPercent {
    final cpuData = cpuTotal;
    if (cpuData == null) return null;

    final fields = cpuData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final userUsage = fields['usage_user'];
    if (userUsage == null) return null;

    return (userUsage is num) ? userUsage.toDouble().ceil() : null;
  }

  /// Get CPU system usage percentage
  int? get cpuSystemPercent {
    final cpuData = cpuTotal;
    if (cpuData == null) return null;

    final fields = cpuData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final systemUsage = fields['usage_system'];
    if (systemUsage == null) return null;

    return (systemUsage is num) ? systemUsage.toDouble().ceil() : null;
  }

  /// Get CPU I/O wait percentage
  int? get cpuIOwaitPercent {
    final cpuData = cpuTotal;
    if (cpuData == null) return null;

    final fields = cpuData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final iowaitUsage = fields['usage_iowait'];
    if (iowaitUsage == null) return null;

    return (iowaitUsage is num) ? iowaitUsage.toDouble().ceil() : null;
  }

  /// SYSTEM DATA
  Map<String, dynamic>? get system {
    final systemList = getByName('system');
    return systemList.isNotEmpty ? systemList.first : null;
  }

  /// Get hostname from any data entry (all Telegraf entries should have host tag)
  String? get hostname {
    // Look through all data entries for a host tag
    for (final entry in _data) {
      final tags = entry['tags'] as Map<String, dynamic>?;
      if (tags != null && tags.containsKey('host')) {
        return tags['host'] as String?;
      }
    }
    return null;
  }

  /// Get the most recent timestamp from all data entries
  DateTime? get lastUpdated {
    DateTime? mostRecent;

    for (final entry in _data) {
      final timestamp = entry['timestamp'];
      if (timestamp != null) {
        try {
          DateTime dateTime;

          if (timestamp is String) {
            // Parse ISO 8601 string timestamp
            dateTime = DateTime.parse(timestamp);
          } else if (timestamp is int) {
            // Detect format by number of digits
            final timestampStr = timestamp.toString();
            final digitCount = timestampStr.length;

            if (digitCount >= 19) {
              // Nanoseconds (19 digits): 1721034600123456789
              dateTime = DateTime.fromMillisecondsSinceEpoch(
                timestamp ~/ 1000000,
              );
            } else if (digitCount >= 16) {
              // Microseconds (16 digits): 1721034600123456
              dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp ~/ 1000);
            } else if (digitCount >= 13) {
              // Milliseconds (13 digits): 1721034600123
              dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            } else if (digitCount >= 10) {
              // Seconds (10 digits): 1721034600
              dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
            } else {
              // Invalid timestamp, skip
              continue;
            }
          } else if (timestamp is double) {
            // Convert to int and apply same logic
            final intTimestamp = timestamp.round();
            final timestampStr = intTimestamp.toString();
            final digitCount = timestampStr.length;

            if (digitCount >= 19) {
              dateTime = DateTime.fromMillisecondsSinceEpoch(
                intTimestamp ~/ 1000000,
              );
            } else if (digitCount >= 16) {
              dateTime = DateTime.fromMillisecondsSinceEpoch(
                intTimestamp ~/ 1000,
              );
            } else if (digitCount >= 13) {
              dateTime = DateTime.fromMillisecondsSinceEpoch(intTimestamp);
            } else if (digitCount >= 10) {
              dateTime = DateTime.fromMillisecondsSinceEpoch(
                intTimestamp * 1000,
              );
            } else {
              continue;
            }
          } else {
            // Skip unsupported timestamp formats
            continue;
          }

          // Sanity check: make sure date is between 2020 and 2030
          final year = dateTime.year;
          if (year < 2020 || year > 2030) {
            // Invalid date, skip this entry
            continue;
          }

          if (mostRecent == null || dateTime.isAfter(mostRecent)) {
            mostRecent = dateTime;
          }
        } catch (e) {
          // Skip invalid timestamps
          continue;
        }
      }
    }

    return mostRecent;
  }

  /// Get formatted last updated string with exact date and time
  String? get lastUpdatedFormatted {
    final lastUpdate = lastUpdated;
    if (lastUpdate == null) return null;

    // Format as: "15 Jul 2025, 14:30"
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final day = lastUpdate.day;
    final month = months[lastUpdate.month - 1];
    final year = lastUpdate.year;
    final hour = lastUpdate.hour.toString().padLeft(2, '0');
    final minute = lastUpdate.minute.toString().padLeft(2, '0');

    return "$day $month $year, $hour:$minute";
  }

  /// Check if the data is stale (no updates received recently)
  bool get isDataStale {
    final lastUpdate = lastUpdated;
    if (lastUpdate == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    // Consider data stale if no updates for more than 5 minutes
    return difference.inMinutes > 5;
  }

  /// Get data freshness status with visual indicator
  String get dataFreshnessStatus {
    final lastUpdate = lastUpdated;
    if (lastUpdate == null) return "🔴 No data";

    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference.inMinutes <= 2) {
      return "🟢 Live"; // Fresh data
    } else if (difference.inMinutes <= 5) {
      return "🟡 Recent"; // Slightly old but acceptable
    } else if (difference.inMinutes <= 15) {
      return "🟠 Stale"; // Getting old
    } else {
      return "🔴 Offline"; // Very old, likely disconnected
    }
  }

  /// Get uptime in seconds
  int? get uptimeSeconds {
    final systemList = getByName('system');
    // Look for the system entry that has uptime field
    for (final systemData in systemList) {
      final fields = systemData['fields'] as Map<String, dynamic>?;
      if (fields != null && fields.containsKey('uptime')) {
        final uptime = fields['uptime'];
        return (uptime is num) ? uptime.toInt() : null;
      }
    }
    return null;
  }

  /// Get formatted uptime string (e.g., "33 days, 5:35")
  String? get uptimeFormatted {
    final systemList = getByName('system');
    // Look for the system entry that has uptime_format field
    for (final systemData in systemList) {
      final fields = systemData['fields'] as Map<String, dynamic>?;
      if (fields != null && fields.containsKey('uptime_format')) {
        return fields['uptime_format'] as String?;
      }
    }
    return null;
  }

  /// Get compact uptime string for display (e.g., "33d 5h")
  String? get uptimeCompact {
    final seconds = uptimeSeconds;
    if (seconds == null) return null;

    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (days > 0) {
      return "${days}d ${hours}h";
    } else if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }

  /// DISK DATA
  Map<String, dynamic>? get disk {
    final diskList = getByName('disk');
    // Look for the root disk (path="/")
    for (final diskData in diskList) {
      final tags = diskData['tags'] as Map<String, dynamic>?;
      if (tags != null && tags['path'] == '/') {
        return diskData;
      }
    }
    // If no root disk found, return the first one
    return diskList.isNotEmpty ? diskList.first : null;
  }

  /// Get disk usage percentage
  int? get diskUsagePercent {
    final diskData = disk;
    if (diskData == null) return null;

    final fields = diskData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final usedPercent = fields['used_percent'];
    if (usedPercent == null) return null;

    return (usedPercent is num) ? usedPercent.toDouble().ceil() : null;
  }

  /// Get disk free space in GB
  int? get diskFreeGB {
    final diskData = disk;
    if (diskData == null) return null;

    final fields = diskData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final free = fields['free'];
    if (free == null) return null;

    return (free is num)
        ? (free.toDouble() / 1024 / 1024 / 1024).round()
        : null;
  }

  /// Get disk total space in GB
  int? get diskTotalGB {
    final diskData = disk;
    if (diskData == null) return null;

    final fields = diskData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final total = fields['total'];
    if (total == null) return null;

    return (total is num)
        ? (total.toDouble() / 1024 / 1024 / 1024).round()
        : null;
  }

  /// NETWORK DATA
  List<Map<String, dynamic>> get networkInterfaces {
    return getByName('net');
  }

  /// Get primary network interface (excluding loopback and virtual interfaces)
  Map<String, dynamic>? get primaryNetworkInterface {
    final interfaces = networkInterfaces;

    // Look for primary interfaces (excluding docker, lo, etc.)
    for (final iface in interfaces) {
      final tags = iface['tags'] as Map<String, dynamic>?;
      if (tags != null) {
        final interfaceName = tags['interface'] as String?;
        if (interfaceName != null &&
            !interfaceName.startsWith('docker') &&
            !interfaceName.startsWith('br-') &&
            !interfaceName.startsWith('veth') &&
            interfaceName != 'lo' &&
            interfaceName != 'all') {
          return iface;
        }
      }
    }

    // Fallback to first interface if no primary found
    return interfaces.isNotEmpty ? interfaces.first : null;
  }

  /// Get network bytes received per second (approximate)
  String? get networkReceiveMBps {
    final netData = primaryNetworkInterface;
    if (netData == null) return null;

    final fields = netData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final bytesRecv = fields['bytes_recv'];
    if (bytesRecv == null) return null;

    // This is total bytes, for rate we'd need time series data
    // For now, we'll show a simplified version
    if (bytesRecv is num) {
      final mbps = (bytesRecv.toDouble() / 1024 / 1024).toStringAsFixed(1);
      return "${mbps}M";
    }
    return null;
  }

  /// Get network bytes sent per second (approximate)
  String? get networkSentMBps {
    final netData = primaryNetworkInterface;
    if (netData == null) return null;

    final fields = netData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final bytesSent = fields['bytes_sent'];
    if (bytesSent == null) return null;

    if (bytesSent is num) {
      final mbps = (bytesSent.toDouble() / 1024 / 1024).toStringAsFixed(1);
      return "${mbps}M";
    }
    return null;
  }

  /// Get network packets received
  int? get networkPacketsReceived {
    final netData = primaryNetworkInterface;
    if (netData == null) return null;

    final fields = netData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final packetsRecv = fields['packets_recv'];
    if (packetsRecv == null) return null;

    return (packetsRecv is num) ? packetsRecv.toInt() : null;
  }

  /// Get network packets sent
  int? get networkPacketsSent {
    final netData = primaryNetworkInterface;
    if (netData == null) return null;

    final fields = netData['fields'] as Map<String, dynamic>?;
    if (fields == null) return null;

    final packetsSent = fields['packets_sent'];
    if (packetsSent == null) return null;

    return (packetsSent is num) ? packetsSent.toInt() : null;
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
