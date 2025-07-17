import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/resource.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/views/principal/home/token.dart';
import 'package:tinyfal/src/views/principal/home/delete_resource_dialog.dart';

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
    // Convert bytes to GB, fallback to estimating from disk total if not available
    final diskTotal = _status?.diskTotalGB?.toDouble() ?? 500.0;
    return diskTotal *
        0.016; // Rough estimate: ~1.6% of disk space is typical for RAM
  }

  double get _memoryUsedGB {
    final totalGB = _memoryTotalGB;
    final usedPercent = _memoryUsage;
    return (totalGB * usedPercent / 100);
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
  int get _swapTotalGB => _status?.swapTotalGB ?? 0;
  int get _swapUsedMB => _status?.swapUsedMB ?? 0;

  // Process breakdown
  int get _runningProcesses => _status?.runningProcesses ?? 0;
  int get _sleepingProcesses => _status?.sleepingProcesses ?? 0;
  int get _idleProcesses => _status?.idleProcesses ?? 0;
  int get _zombieProcesses => _status?.zombieProcesses ?? 0;

  Color _getUsageColor(int usage) {
    if (usage < 30) return Colors.green[400]!;
    if (usage < 70) return Colors.orange[400]!;
    return Colors.red[400]!;
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
          widget.resource.title ?? "Server Details",
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
            //_buildAllDiskDevicesCard(),
            //SizedBox(height: 16),

            // Network & Docker
            //_buildNetworkDockerCard(),
            //SizedBox(height: 16),

            // Process Details
            _buildProcessDetailsCard(),
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
                  Text(
                    "Status: Online",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Active",
                      style: TextStyle(
                        color: Colors.green[700],
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
          _buildInfoRow("Token", widget.resource.token ?? "Not Generated"),
          _buildInfoRow("Hostname", _hostName),
          _buildInfoRow("OS", "Linux"),
          _buildInfoRow("Architecture", "x86_64"),
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
}
