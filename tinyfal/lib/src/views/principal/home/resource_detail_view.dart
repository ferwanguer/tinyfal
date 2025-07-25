import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/resource.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/views/principal/home/token.dart';
import 'package:tinyfal/src/views/principal/home/delete_resource_dialog.dart';
import 'package:tinyfal/src/services/database.dart';

//TODO refactor
class ResourceDetailView extends StatefulWidget {
  final Resource resource;
  final ClientUser? clientUser;
  final Preferences? preferences;

  const ResourceDetailView({
    super.key,
    required this.resource,
    required this.preferences,
    required this.clientUser,
  });

  @override
  State<ResourceDetailView> createState() => _ResourceDetailViewState();
}

class _ResourceDetailViewState extends State<ResourceDetailView> {
  // Helper getter for the status data
  Status? get _status => widget.resource.status;

  // Data getters using Status class
  int get _cpuUsage => _status?.cpuUsagePercent ?? 0;
  int get _memoryUsage => _status?.usedMemoryPercent ?? 0;
  int get _swapUsage => _status?.usedSwapPercent ?? 0;
  int get _diskUsage => _status?.diskUsagePercent ?? 0;
  int get _processes => _status?.totalProcesses ?? 0;
  int get _threads => _status?.totalThreads ?? 0;
  String get _hostName => _status?.hostname ?? "Unknown";
  String? get _uptimeFormatted => _status?.uptimeFormatted;
  String? get _lastUpdateFormatted => _status?.lastUpdatedFormatted;

  // System information
  int get _numberOfCpus => _status?.numberOfCpus ?? 0;

  // Memory information in GB
  double get _memoryTotalGB {
    // Get actual memory total from telegraf data
    return _status?.memoryTotalGB ?? 0.0;
  }

  double get _memoryUsedGB {
    // Get actual memory used from telegraf data
    return _status?.memoryUsedGB ?? 0.0;
  }

  // Disk information
  int get _diskTotalGB => _status?.diskTotalGB ?? 0;
  int get _diskUsedGB => _status?.diskUsedGB ?? 0;
  int get _diskFreeGB => _status?.diskFreeGB ?? 0;
  String get _diskDevice => _status?.diskDevice ?? "Unknown";
  String get _diskFstype => _status?.diskFstype ?? "Unknown";

  // Inode information
  int get _inodeUsage => _status?.diskInodesUsagePercent ?? 0;
  int get _inodesUsed => _status?.diskInodesUsed ?? 0;
  int get _inodesTotal => _status?.diskInodesTotal ?? 0;

  // Swap information
  num get _swapTotalGB => _status?.swapTotalGB ?? 0;
  int get _swapUsedMB => _status?.swapUsedMB ?? 0;

  // Process breakdown
  int get _runningProcesses => _status?.runningProcesses ?? 0;
  int get _sleepingProcesses => _status?.sleepingProcesses ?? 0;
  int get _idleProcesses => _status?.idleProcesses ?? 0;
  int get _zombieProcesses => _status?.zombieProcesses ?? 0;

  // Network connection data
  int get _tcpEstablished => _status?.tcpEstablished ?? 0;
  int get _tcpListen => _status?.tcpListen ?? 0;
  int get _tcpTimeWait => _status?.tcpTimeWait ?? 0;
  int get _tcpCloseWait => _status?.tcpCloseWait ?? 0;
  int get _udpSockets => _status?.udpSockets ?? 0;

  Color _getUsageColor(int usage) {
    if (usage < 30) return Colors.green[400]!;
    if (usage < 70) return Colors.orange[400]!;
    return Colors.red[400]!;
  }

  // Helper method to determine status based on data freshness
  String _getStatusType() {
    final freshnessStatus = _status?.dataFreshnessStatus ?? "🔴 No data";
    if (freshnessStatus.contains('🟢')) return "online";
    if (freshnessStatus.contains('🟡')) return "stale";
    return "offline";
  }

  Color _getStatusColor() {
    switch (_getStatusType()) {
      case "online":
        return Colors.green[400]!;
      case "stale":
        return Colors.orange[400]!;
      default:
        return Colors.red[400]!;
    }
  }

  Color _getStatusBackgroundColor() {
    switch (_getStatusType()) {
      case "online":
        return Colors.green[50]!;
      case "stale":
        return Colors.orange[50]!;
      default:
        return Colors.red[50]!;
    }
  }

  Color _getStatusBorderColor() {
    switch (_getStatusType()) {
      case "online":
        return Colors.green[200]!;
      case "stale":
        return Colors.orange[200]!;
      default:
        return Colors.red[200]!;
    }
  }

  Color _getStatusTextColor() {
    switch (_getStatusType()) {
      case "online":
        return Colors.green[700]!;
      case "stale":
        return Colors.orange[700]!;
      default:
        return Colors.red[700]!;
    }
  }

  String _getStatusLabel() {
    switch (_getStatusType()) {
      case "online":
        return "Online";
      case "stale":
        return "Stale";
      default:
        return "Offline";
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteResourceDialog(resource: widget.resource),
    );

    if (result == true && mounted) {
      // Resource was deleted, navigate back to the previous screen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Details",
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        actions: [
          IconButton(
            onPressed: () => _showDeleteDialog(context),
            icon: Icon(Icons.delete, color: Colors.red[600]),
            tooltip: 'Delete Resource',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),
            SizedBox(height: 16),

            // System Overview
            _buildSystemOverviewCard(),
            SizedBox(height: 16),

            // Storage & Network
            _buildStorageNetworkCard(),
            SizedBox(height: 16),

            // All Disk Devices
            _buildAllDiskDevicesCard(),
            SizedBox(height: 16),

            // Docker Information
            _buildDockerCard(),
            SizedBox(height: 16),

            // Process Details
            _buildProcessDetailsCard(),
            SizedBox(height: 16),

            // Network Connections
            _buildNetworkConnectionsCard(),
            SizedBox(height: 16),

            // System Information
            _buildSystemInfoCard(),
            SizedBox(height: 16),

            // Token Management
            TokenManagementCard(
              resource: widget.resource,
              clientUser: widget.clientUser,
              onTokenRegenerated: (newToken) {
                // Handle token regeneration if needed
                // You might want to update the UI or notify parent widgets
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.resource.title ?? "Unknown Server",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "Last Update ${_lastUpdateFormatted ?? 'Unknown'}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                      SizedBox(width: 8),
                      Text(
                        _status?.dataFreshnessStatus ?? "🔴 No data",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusBorderColor()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      _getStatusLabel(),
                      style: TextStyle(
                        color: _getStatusTextColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem("Uptime", _uptimeFormatted ?? "Unknown"),
              ),
              Expanded(child: _buildInfoItem("Processes", "$_processes")),
              Expanded(
                child: _buildInfoItem(
                  "Last Update",
                  _lastUpdateFormatted ?? "Unknown",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemOverviewCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "System Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildCircularMetric("CPU", _cpuUsage, "%")),
              Expanded(
                child: _buildCircularMetric("Memory", _memoryUsage, "%"),
              ),
              Expanded(child: _buildCircularMetric("Disk", _diskUsage, "%")),
              Expanded(child: _buildCircularMetric("Network", 15, "%")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageNetworkCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Storage & Memory",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          _buildProgressBar(
            "Memory Usage",
            "${_memoryUsedGB.toStringAsFixed(1)} GB / ${_memoryTotalGB.toStringAsFixed(1)} GB",
            _memoryUsage / 100,
            _getUsageColor(_memoryUsage),
          ),
          SizedBox(height: 16),
          _buildProgressBar(
            "Swap Usage",
            "${_swapUsedMB} MB / ${_swapTotalGB} GB",
            _swapUsage / 100,
            _getUsageColor(_swapUsage),
          ),
          SizedBox(height: 16),
          _buildProgressBar(
            "Main Disk ($_diskDevice)",
            "$_diskUsedGB GB / $_diskTotalGB GB",
            _diskUsage / 100,
            _getUsageColor(_diskUsage),
          ),
          SizedBox(height: 16),
          _buildProgressBar(
            "Inodes (File System Objects)",
            "${_inodesUsed} / ${_inodesTotal} inodes",
            _inodeUsage / 100,
            _getUsageColor(_inodeUsage),
          ),
          SizedBox(height: 16),
          _buildDiskDetailsRow(),
        ],
      ),
    );
  }

  Widget _buildDiskDetailsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Disk Details",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Device Information",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "Device: $_diskDevice",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    "Filesystem: $_diskFstype",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Space Usage",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "Used: $_diskUsedGB GB",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    "Free: $_diskFreeGB GB",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "System Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          _buildInfoRow("Server ID", widget.resource.uid ?? "N/A"),
          _buildInfoRow("Client ID", widget.clientUser?.uid ?? "N/A"),

          _buildInfoRow("Hostname", _hostName),
          _buildInfoRow("CPU Cores", "$_numberOfCpus"),
          _buildInfoRow("Last Update", _lastUpdateFormatted ?? "Unknown"),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularMetric(String label, int value, String unit) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          child: Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getUsageColor(value),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "$value$unit",
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
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      ],
    );
  }

  Widget _buildProgressBar(
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessDetailsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Process Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildProcessStat("Total", "$_processes", "")),
              Expanded(
                child: _buildProcessStat("Running", "$_runningProcesses", ""),
              ),
              Expanded(
                child: _buildProcessStat("Sleeping", "$_sleepingProcesses", ""),
              ),
              Expanded(child: _buildProcessStat("Idle", "$_idleProcesses", "")),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildProcessStat("Threads", "$_threads", "")),
              Expanded(
                child: _buildProcessStat(
                  "Zombies",
                  "$_zombieProcesses",
                  _zombieProcesses > 0 ? "⚠️" : "✅",
                ),
              ),
              Expanded(child: Container()), // Empty space
              Expanded(child: Container()), // Empty space
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStat(String label, String value, String percentage) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[600],
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        if (percentage.isNotEmpty)
          Text(
            percentage,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
      ],
    );
  }

  Widget _buildNetworkConnectionsCard() {
    // Don't show if no TCP/UDP data available
    if (_tcpEstablished == 0 &&
        _tcpListen == 0 &&
        _tcpTimeWait == 0 &&
        _tcpCloseWait == 0 &&
        _udpSockets == 0) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.network_check, color: Colors.blue[600], size: 20),
              SizedBox(width: 8),
              Text(
                "Network Connections",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // TCP Connections section
          Text(
            "TCP Connections",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildConnectionStat(
                  "Established",
                  "$_tcpEstablished",
                  Colors.green[600]!,
                  "Active connections",
                ),
              ),
              Expanded(
                child: _buildConnectionStat(
                  "Listening",
                  "$_tcpListen",
                  Colors.blue[600]!,
                  "Accepting connections",
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildConnectionStat(
                  "Time Wait",
                  "$_tcpTimeWait",
                  Colors.orange[600]!,
                  "Closing connections",
                ),
              ),
              Expanded(
                child: _buildConnectionStat(
                  "Close Wait",
                  "$_tcpCloseWait",
                  Colors.red[600]!,
                  "Waiting to close",
                ),
              ),
            ],
          ),

          if (_udpSockets > 0) ...[
            SizedBox(height: 20),

            // UDP Sockets section
            Text(
              "UDP Sockets",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildConnectionStat(
                    "UDP Sockets",
                    "$_udpSockets",
                    Colors.purple[600]!,
                    "Active UDP connections",
                  ),
                ),
                Expanded(child: Container()), // Empty space
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionStat(
    String label,
    String value,
    Color color,
    String description,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAllDiskDevicesCard() {
    final allDisks = _status?.allDisks ?? [];

    // Filter out the main disk (root filesystem) since it's already shown above
    final otherDisks = allDisks.where((disk) {
      final tags = disk['tags'] as Map<String, dynamic>?;
      return tags != null && tags['path'] != '/';
    }).toList();

    // Don't show the card if there are no other disks
    if (otherDisks.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Additional Storage Devices",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          ...otherDisks.map((disk) => _buildDiskEntry(disk)).toList(),
        ],
      ),
    );
  }

  Widget _buildDiskEntry(Map<String, dynamic> disk) {
    final tags = disk['tags'] as Map<String, dynamic>?;
    final fields = disk['fields'] as Map<String, dynamic>?;

    if (tags == null || fields == null) return SizedBox.shrink();

    final path = tags['path'] as String? ?? 'Unknown';
    final device = tags['device'] as String? ?? 'Unknown';
    final fstype = tags['fstype'] as String? ?? 'Unknown';

    final total = fields['total'] as num?;
    final free = fields['free'] as num?;

    if (total == null || free == null) return SizedBox.shrink();

    // Calculate usage using btop-style calculation
    final used = total.toDouble() - free.toDouble();
    final usagePercent = (used / total.toDouble() * 100).round();
    final totalGB = (total.toDouble() / 1024 / 1024 / 1024);
    final usedGB = (used / 1024 / 1024 / 1024);
    final freeGB = (free.toDouble() / 1024 / 1024 / 1024);

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$path ($device)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      "Type: $fstype",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Text(
                "${usedGB.toStringAsFixed(2)} GB / ${totalGB.toStringAsFixed(2)} GB",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: usagePercent / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getUsageColor(usagePercent),
            ),
            minHeight: 6,
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Used: $usagePercent%",
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              Text(
                "Free: ${freeGB.toStringAsFixed(2)} GB",
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDockerCard() {
    // Get all Docker-related data
    final containerStatus = _status?.dockerContainerStatus ?? [];
    final containerMemory = _status?.dockerContainerMemory ?? [];
    final containerCpu = _status?.dockerContainerCpu ?? [];

    // Get basic Docker stats
    final totalContainers = _status?.dockerContainersTotal ?? 0;
    final runningContainers = _status?.dockerContainersRunning ?? 0;

    // Don't show if no Docker data
    if (totalContainers == 0) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.developer_board, color: Colors.blue[600], size: 20),
              SizedBox(width: 8),
              Text(
                "Docker Containers",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: runningContainers > 0
                      ? Colors.green[100]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$runningContainers/$totalContainers running",
                  style: TextStyle(
                    fontSize: 12,
                    color: runningContainers > 0
                        ? Colors.green[700]
                        : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Show running containers if any
          if (runningContainers > 0) ...[
            ...containerStatus.map(
              (container) =>
                  _buildContainerItem(container, containerMemory, containerCpu),
            ),
          ] else ...[
            // Show no running containers message
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "No containers are currently running",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContainerItem(
    Map<String, dynamic> container,
    List<Map<String, dynamic>> memoryData,
    List<Map<String, dynamic>> cpuData,
  ) {
    final tags = container['tags'] as Map<String, dynamic>?;
    final fields = container['fields'] as Map<String, dynamic>?;

    if (tags == null || fields == null) return SizedBox.shrink();

    // Extract container information from tags
    final containerName = tags['container_name'] as String? ?? 'Unknown';
    final containerImage = tags['container_image'] as String? ?? 'Unknown';
    final containerVersion = tags['container_version'] as String? ?? 'latest';

    // Extract uptime and other info from fields
    final uptimeNs = fields['uptime_ns'] as num? ?? 0;
    final uptimeSeconds =
        uptimeNs / 1000000000; // Convert nanoseconds to seconds
    final pid = fields['pid'] as num? ?? 0;
    final exitCode = fields['exitcode'] as num? ?? 0;

    // Find memory data for this container
    final containerMemory = memoryData.firstWhere((mem) {
      final memTags = mem['tags'] as Map<String, dynamic>?;
      return memTags != null && memTags['container_name'] == containerName;
    }, orElse: () => <String, dynamic>{});

    // Find CPU data for this container
    final containerCpuData = cpuData.firstWhere((cpu) {
      final cpuTags = cpu['tags'] as Map<String, dynamic>?;
      return cpuTags != null && cpuTags['container_name'] == containerName;
    }, orElse: () => <String, dynamic>{});

    // Extract memory info
    final memFields = containerMemory['fields'] as Map<String, dynamic>?;
    final memUsage = memFields?['usage'] as num? ?? 0;
    final memUsageMB = memUsage / 1024 / 1024;

    // Extract CPU info
    final cpuFields = containerCpuData['fields'] as Map<String, dynamic>?;
    final cpuUsage = cpuFields?['usage_percent'] as num? ?? 0;

    // Format uptime
    final uptimeDuration = Duration(seconds: uptimeSeconds.round());
    final uptimeFormatted = _formatDuration(uptimeDuration);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container header
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: exitCode == 0 ? Colors.green[400] : Colors.red[400],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      containerName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      "$containerImage:$containerVersion",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: exitCode == 0 ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exitCode == 0 ? "RUNNING" : "ERROR",
                  style: TextStyle(
                    fontSize: 10,
                    color: exitCode == 0 ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Container details
          Row(
            children: [
              Expanded(child: _buildContainerDetailItem("PID", "$pid")),
              Expanded(
                child: _buildContainerDetailItem("Uptime", uptimeFormatted),
              ),
            ],
          ),

          if (memUsage > 0 || cpuUsage > 0) ...[
            SizedBox(height: 12),
            // Resource usage
            Row(
              children: [
                if (cpuUsage > 0)
                  Expanded(
                    child: _buildContainerDetailItem(
                      "CPU",
                      "${cpuUsage.toStringAsFixed(1)}%",
                    ),
                  ),
                if (memUsage > 0 && cpuUsage > 0) SizedBox(width: 16),
                if (memUsage > 0)
                  Expanded(
                    child: _buildContainerDetailItem(
                      "Memory",
                      "${memUsageMB.toStringAsFixed(0)} MB",
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContainerDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return "${days}d ${hours}h";
    } else if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }
}

class ResourceDetailPage extends StatelessWidget {
  final String userId;
  final String resourceId;
  final ClientUser? clientUser;
  final Preferences? preferences;

  const ResourceDetailPage({
    super.key,
    required this.userId,
    required this.resourceId,
    this.clientUser,
    this.preferences,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Resource?>(
      stream: getResourceStream(userId, resourceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text("Loading...")),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text("Error")),
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: Text("Not Found")),
            body: Center(child: Text("Resource not found")),
          );
        }

        final resource = snapshot.data!;
        return ResourceDetailView(
          resource: resource,
          preferences: preferences,
          clientUser: clientUser,
        );
      },
    );
  }
}
