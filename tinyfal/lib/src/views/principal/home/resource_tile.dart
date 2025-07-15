import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/resource.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/views/principal/home/resource_detail_view.dart';

class ResourceTile extends StatelessWidget {
  final Resource resource;
  final ClientUser? clientUser;
  final Preferences? preferences;

  const ResourceTile({
    super.key,
    required this.resource,
    required this.preferences,
    required this.clientUser,
  });

  // Mock data generators for demonstration
  int get _cpuUsage => Random().nextInt(50) + 1; // 1-50%
  int get _memoryUsage => Random().nextInt(80) + 5; // 5-85%
  int get _temperature => Random().nextInt(40) + 30; // 30-70°C
  double get _readSpeed => Random().nextDouble() * 10; // 0-10 M/s
  double get _writeSpeed => Random().nextDouble() * 8; // 0-8 M/s
  int get _readOps => Random().nextInt(1000); // 0-1000 ops
  int get _writeOps => Random().nextInt(500); // 0-500 ops

  String get _lastUpdate {
    final minutes = Random().nextInt(30) + 1; // 1-30 minutes ago
    return "${minutes}m ago";
  }

  @override
  Widget build(BuildContext context) {
    if (preferences == null) {
      return CircularProgressIndicator();
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResourceDetailView(
              resource: resource,
              clientUser: clientUser,
              preferences: preferences,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with server name, temperature and icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.title ?? "server",
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Updated $_lastUpdate",
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "$_temperature°C",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      SizedBox(width: 12),
                      Container(
                        width: 8,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.orange[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Column(
                          children: List.generate(
                            4,
                            (index) => Container(
                              height: 3,
                              margin: EdgeInsets.symmetric(vertical: 0.5),
                              color: Colors.orange[200 + (index * 50)],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.computer, color: Colors.orange[400], size: 20),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Metrics row
              Row(
                children: [
                  // CPU Circle
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          child: Stack(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  value: _cpuUsage / 100,
                                  strokeWidth: 5,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _cpuUsage < 30
                                        ? Colors.blue[400]!
                                        : _cpuUsage < 70
                                        ? Colors.orange[400]!
                                        : Colors.red[400]!,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  "$_cpuUsage%",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "CPU",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Memory Circle
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          child: Stack(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  value: _memoryUsage / 100,
                                  strokeWidth: 4,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _memoryUsage < 30
                                        ? Colors.blue[400]!
                                        : _memoryUsage < 70
                                        ? Colors.orange[400]!
                                        : Colors.red[400]!,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  "$_memoryUsage%",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Mem",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // I/O Stats
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Read stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${_readOps}",
                                  style: TextStyle(
                                    color: Colors.blue[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "↑/s",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${_readSpeed.toStringAsFixed(1)}M",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "read/s",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Write stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${_writeOps}",
                                  style: TextStyle(
                                    color: Colors.blue[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "↓/s",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${_writeSpeed.toStringAsFixed(1)}K",
                                  style: TextStyle(
                                    color: Colors.blue[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "write/s",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
