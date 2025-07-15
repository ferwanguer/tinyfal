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
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 600),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Padding(
            key: ValueKey(
              '${resource.status?.lastUpdated?.millisecondsSinceEpoch ?? 0}',
            ),
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
                          resource.status?.hostname ??
                              resource.title ??
                              "server",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              "Last Update ${resource.status?.lastUpdatedFormatted ?? 'Unknown'}",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              resource.status?.dataFreshnessStatus ??
                                  "🔴 No data",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          resource.status?.uptimeCompact ?? "Unknown",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          width: 8,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.green[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Column(
                            children: List.generate(
                              4,
                              (index) => Container(
                                height: 3,
                                margin: EdgeInsets.symmetric(vertical: 0.5),
                                color: Colors.green[200 + (index * 50)],
                              ),
                            ),
                          ),
                        ),
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
                                    value:
                                        resource.status?.cpuUsagePercent != null
                                        ? resource.status!.cpuUsagePercent! /
                                              100
                                        : null,
                                    strokeWidth: 5,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      resource.status?.cpuUsagePercent == null
                                          ? Colors.grey[400]!
                                          : (resource.status!.cpuUsagePercent! <
                                                    30
                                                ? Colors.blue[400]!
                                                : (resource
                                                              .status!
                                                              .cpuUsagePercent! <
                                                          70
                                                      ? Colors.orange[400]!
                                                      : Colors.red[400]!)),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    resource.status?.cpuUsagePercent != null
                                        ? "${resource.status!.cpuUsagePercent}%"
                                        : "...",
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
                                    value:
                                        resource.status?.usedMemoryPercent !=
                                            null
                                        ? resource.status!.usedMemoryPercent! /
                                              100
                                        : null,
                                    strokeWidth: 4,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      (resource.status?.usedMemoryPercent ??
                                                  0) <
                                              50
                                          ? Colors.blue[400]!
                                          : (resource
                                                        .status
                                                        ?.usedMemoryPercent !=
                                                    null &&
                                                (resource
                                                            .status!
                                                            .usedMemoryPercent !=
                                                        null &&
                                                    resource
                                                            .status!
                                                            .usedMemoryPercent! <
                                                        70))
                                          ? Colors.orange
                                          : Colors.red[400]!,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    "${resource.status?.usedMemoryPercent}%",
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
                            "Used Mem",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Network Stats
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Received stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${(resource.status?.networkPacketsReceived ?? 0) ~/ 1000}K",
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "↓ recv",
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
                                    resource.status?.networkReceiveMBps ?? "0M",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "total",
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
                          // Sent stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${(resource.status?.networkPacketsSent ?? 0) ~/ 1000}K",
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "↑ sent",
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
                                    resource.status?.networkSentMBps ?? "0M",
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "total",
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
      ),
    );
  }
}
