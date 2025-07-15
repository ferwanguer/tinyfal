import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tinyfal/src/models/client_user.dart';
import 'package:tinyfal/src/models/resource.dart';
import 'package:tinyfal/src/models/preferences.dart';
import 'package:tinyfal/src/views/principal/home/token.dart';

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
  // Enhanced Telegraf-like data structure based on real output
  Map<String, dynamic> get _telegrafData => {
    'cpu': {
      'total': {
        'usage_idle': 98.25,
        'usage_user': 0.75,
        'usage_system': 0.75,
        'usage_softirq': 0.25,
        'usage_iowait': 0.0,
        'usage_irq': 0.0,
        'usage_steal': 0.0,
        'usage_guest': 0.0,
      },
      'cores': [
        {
          'cpu': 'cpu0',
          'usage_idle': 98.0,
          'usage_user': 2.0,
          'usage_system': 0.0,
        },
        {
          'cpu': 'cpu1',
          'usage_idle': 100.0,
          'usage_user': 0.0,
          'usage_system': 0.0,
        },
        {
          'cpu': 'cpu2',
          'usage_idle': 100.0,
          'usage_user': 0.0,
          'usage_system': 0.0,
        },
        {
          'cpu': 'cpu3',
          'usage_idle': 98.0,
          'usage_user': 2.0,
          'usage_system': 0.0,
        },
        {
          'cpu': 'cpu4',
          'usage_idle': 100.0,
          'usage_user': 0.0,
          'usage_system': 0.0,
        },
        {
          'cpu': 'cpu5',
          'usage_idle': 100.0,
          'usage_user': 0.0,
          'usage_system': 0.0,
        },
        {
          'cpu': 'cpu6',
          'usage_idle': 100.0,
          'usage_user': 0.0,
          'usage_system': 0.0,
        },
        {
          'cpu': 'cpu7',
          'usage_idle': 96.0,
          'usage_user': 2.0,
          'usage_system': 2.0,
        },
      ],
    },
    'memory': {
      'total': 8033329152, // ~7.5 GB
      'used': 1449807872, // ~1.35 GB
      'available': 6027333632, // ~5.6 GB
      'available_percent': 75.03,
      'used_percent': 18.05,
      'free': 315031552,
      'cached': 5557719040,
      'buffered': 710770688,
      'active': 2202644480,
      'inactive': 4583780352,
    },
    'swap': {
      'total': 4294963200, // ~4 GB
      'used': 1572864,
      'free': 4293390336,
      'used_percent': 0.04,
      'in': 0,
      'out': 393216,
    },
    'disk': {
      'main': {
        'device': 'nvme0n1p2',
        'fstype': 'ext4',
        'path': '/',
        'total': 501809635328, // ~467 GB
        'used': 19121623040, // ~17.8 GB
        'free': 457122209792, // ~425 GB
        'used_percent': 4.02,
        'inodes_total': 31195136,
        'inodes_used': 258082,
        'inodes_free': 30937054,
        'inodes_used_percent': 0.83,
      },
      'boot': {
        'device': 'nvme0n1p1',
        'fstype': 'vfat',
        'path': '/boot/efi',
        'total': 1124999168,
        'used': 6434816,
        'free': 1118564352,
        'used_percent': 0.57,
        'inodes_total': 0,
        'inodes_used': 0,
        'inodes_free': 0,
        'inodes_used_percent': 0,
      },
      'efivarfs': {
        'device': 'efivarfs',
        'fstype': 'efivarfs',
        'path': '/sys/firmware/efi/efivars',
        'total': 130984,
        'used': 109180,
        'free': 16684,
        'used_percent': 86.74,
        'inodes_total': 0,
        'inodes_used': 0,
        'inodes_free': 0,
        'inodes_used_percent': 0,
      },
    },
    'network': {
      'interfaces': {
        'wlp2s0': {
          'bytes_recv': 7558140820,
          'bytes_sent': 832446601,
          'packets_recv': 35551309,
          'packets_sent': 2693415,
          'drop_in': 86955,
          'drop_out': 23,
          'err_in': 0,
          'err_out': 0,
          'speed': -1,
        },
        'docker0': {
          'bytes_recv': 0,
          'bytes_sent': 0,
          'packets_recv': 0,
          'packets_sent': 0,
          'drop_in': 0,
          'drop_out': 70356,
          'err_in': 0,
          'err_out': 0,
          'speed': -1,
        },
        'br-77c73a41ea26': {
          'bytes_recv': 533180721,
          'bytes_sent': 209016917,
          'packets_recv': 1041492,
          'packets_sent': 1172895,
          'drop_in': 0,
          'drop_out': 2,
          'err_in': 0,
          'err_out': 0,
          'speed': 10000,
        },
      },
      'tcp_connections': {
        'established': 2,
        'listen': 24,
        'time_wait': 0,
        'close_wait': 0,
        'syn_sent': 0,
        'syn_recv': 0,
        'fin_wait1': 0,
        'fin_wait2': 0,
        'closing': 0,
        'last_ack': 0,
        'close': 0,
        'none': 63,
      },
      'udp_sockets': 63,
    },
    'processes': {
      'total': 295,
      'running': 1,
      'sleeping': 209,
      'idle': 85,
      'blocked': 0,
      'dead': 0,
      'stopped': 0,
      'zombies': 0,
      'total_threads': 871,
      'paging': 0,
      'unknown': 0,
    },
    'docker': {
      'engine': {
        'containers_total': 6,
        'containers_running': 1,
        'containers_stopped': 5,
        'containers_paused': 0,
        'images': 6,
        'memory_total': 8033329152,
      },
      'containers': {
        'pihole': {
          'name': 'pihole',
          'image': 'pihole/pihole:latest',
          'status': 'running',
          'health': 'healthy',
          'uptime_ns': 2490754105603754,
          'cpu_usage_percent': 0.38,
          'memory_usage': 40558592,
          'memory_usage_percent': 0.50,
          'memory_limit': 8033329152,
          'network_rx_bytes': 218268696,
          'network_tx_bytes': 500440339,
          'network_rx_packets': 1126076,
          'network_tx_packets': 927374,
          'blkio_read_bytes': 28565504,
          'blkio_write_bytes': 4646313984,
        },
      },
    },
    'system': {
      'host': 'canillas',
      'uptime': 2850788, // seconds
      'uptime_format': "32 days, 23:53",
      'load1': 0.03,
      'load5': 0.04,
      'load15': 0.0,
      'n_cpus': 8,
      'n_users': 2,
      'timestamp': 1752581581000,
    },
  };

  // Calculated values from real telegraf data
  int get _cpuUsage =>
      (100 - _telegrafData['cpu']['total']['usage_idle']).round();
  int get _memoryUsage => _telegrafData['memory']['used_percent'].round();
  int get _temperature => Random().nextInt(20) + 45; // Mock temperature
  double get _readSpeed => Random().nextDouble() * 10;
  double get _writeSpeed => Random().nextDouble() * 8;
  int get _readOps => Random().nextInt(1000);
  int get _writeOps => Random().nextInt(500);
  double get _uptime =>
      _telegrafData['system']['uptime'] / 3600.0; // Convert seconds to hours
  double get _ramTotal =>
      _telegrafData['memory']['total'] / (1024 * 1024 * 1024); // Convert to GB

  // Calculated from telegraf data
  int get _processes => _telegrafData['processes']['total'];
  double get _diskTotal =>
      _telegrafData['disk']['main']['total'] /
      (1024 * 1024 * 1024); // Convert to GB
  double get _diskUsed =>
      _telegrafData['disk']['main']['used'] /
      (1024 * 1024 * 1024); // Convert to GB
  int get _diskUsage => _telegrafData['disk']['main']['used_percent'].round();
  String get _hostName => _telegrafData['system']['host'];

  // Inode calculations
  int get _inodeUsage =>
      _telegrafData['disk']['main']['inodes_used_percent'].round();
  int get _inodesUsed => _telegrafData['disk']['main']['inodes_used'];
  int get _inodesTotal => _telegrafData['disk']['main']['inodes_total'];

  String get _lastUpdateDetailed {
    final now = DateTime.now();
    final lastUpdate = DateTime.fromMillisecondsSinceEpoch(
      _telegrafData['system']['timestamp'],
    );
    final difference = now.difference(lastUpdate);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} minutes ago";
    } else {
      return "${difference.inHours} hours ago";
    }
  }

  Color _getUsageColor(int usage) {
    if (usage < 30) return Colors.green[400]!;
    if (usage < 70) return Colors.orange[400]!;
    return Colors.red[400]!;
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

            // Performance Metrics
            _buildPerformanceMetricsCard(),
            SizedBox(height: 16),

            // Storage & Network
            _buildStorageNetworkCard(),
            SizedBox(height: 16),

            // All Disk Devices
            _buildAllDiskDevicesCard(),
            SizedBox(height: 16),

            // Network & Docker
            _buildNetworkDockerCard(),
            SizedBox(height: 16),

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
                child: _buildInfoItem(
                  "Uptime",
                  "${_uptime.toStringAsFixed(1)}h",
                ),
              ),
              Expanded(child: _buildInfoItem("Temperature", "$_temperature°C")),
              Expanded(child: _buildInfoItem("Processes", "$_processes")),
              Expanded(
                child: _buildInfoItem("Last Update", _lastUpdateDetailed),
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

  Widget _buildPerformanceMetricsCard() {
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
            "Performance Metrics",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildMetricRow(
                      "Read Operations",
                      "$_readOps/s",
                      Colors.blue[600]!,
                    ),
                    SizedBox(height: 12),
                    _buildMetricRow(
                      "Write Operations",
                      "$_writeOps/s",
                      Colors.blue[600]!,
                    ),
                    SizedBox(height: 12),
                    _buildMetricRow(
                      "Read Speed",
                      "${_readSpeed.toStringAsFixed(1)} MB/s",
                      Colors.grey[600]!,
                    ),
                    SizedBox(height: 12),
                    _buildMetricRow(
                      "Write Speed",
                      "${_writeSpeed.toStringAsFixed(1)} MB/s",
                      Colors.grey[600]!,
                    ),
                  ],
                ),
              ),
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
            "${(_ramTotal * _memoryUsage / 100).toStringAsFixed(1)} GB / ${_ramTotal.toStringAsFixed(1)} GB",
            _memoryUsage / 100,
            _getUsageColor(_memoryUsage),
          ),
          SizedBox(height: 16),
          _buildProgressBar(
            "Swap Usage",
            "${(_telegrafData['swap']['used'] / (1024 * 1024)).toStringAsFixed(1)} MB / ${(_telegrafData['swap']['total'] / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB",
            _telegrafData['swap']['used_percent'] / 100,
            _getUsageColor(_telegrafData['swap']['used_percent'].round()),
          ),
          SizedBox(height: 16),
          _buildProgressBar(
            "Main Disk (${_telegrafData['disk']['main']['device']})",
            "${_diskUsed.toStringAsFixed(1)} GB / ${_diskTotal.toStringAsFixed(1)} GB",
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
    final mainDisk = _telegrafData['disk']['main'];
    final bootDisk = _telegrafData['disk']['boot'];

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
                    "Main Storage",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "${mainDisk['device']} (${mainDisk['fstype']})",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    "Path: ${mainDisk['path']}",
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
                    "Boot Partition",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "${bootDisk['device']} (${bootDisk['fstype']})",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    "${(bootDisk['used'] / (1024 * 1024)).toStringAsFixed(1)} MB used",
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
          _buildInfoRow("OS", "Linux Ubuntu 22.04"),
          _buildInfoRow("Architecture", "x86_64"),
          _buildInfoRow("CPU Cores", "8"),
          _buildInfoRow("Last Update", _lastUpdateDetailed),
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

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
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
    final processes = _telegrafData['processes'];
    final total = processes['total'];

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
              Expanded(
                child: _buildProcessStat(
                  "Total",
                  processes['total'].toString(),
                  "",
                ),
              ),
              Expanded(
                child: _buildProcessStat(
                  "Running",
                  processes['running'].toString(),
                  "${((processes['running'] / total) * 100).toStringAsFixed(1)}%",
                ),
              ),
              Expanded(
                child: _buildProcessStat(
                  "Sleeping",
                  processes['sleeping'].toString(),
                  "${((processes['sleeping'] / total) * 100).toStringAsFixed(1)}%",
                ),
              ),
              Expanded(
                child: _buildProcessStat(
                  "Idle",
                  processes['idle'].toString(),
                  "${((processes['idle'] / total) * 100).toStringAsFixed(1)}%",
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProcessStat(
                  "Threads",
                  processes['total_threads'].toString(),
                  "total",
                ),
              ),
              Expanded(
                child: _buildProcessStat(
                  "Blocked",
                  processes['blocked'].toString(),
                  "",
                ),
              ),
              Expanded(
                child: _buildProcessStat(
                  "Stopped",
                  processes['stopped'].toString(),
                  "",
                ),
              ),
              Expanded(
                child: _buildProcessStat(
                  "Zombies",
                  processes['zombies'].toString(),
                  "",
                ),
              ),
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

  Widget _buildNetworkDockerCard() {
    final wifiInterface = _telegrafData['network']['interfaces']['wlp2s0'];
    final dockerInterface =
        _telegrafData['network']['interfaces']['br-77c73a41ea26'];
    final dockerEngine = _telegrafData['docker']['engine'];
    final pihole = _telegrafData['docker']['containers']['pihole'];

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
            "Network & Docker",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),

          // Network Interfaces
          Text(
            "Network Interfaces",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),

          _buildNetworkInterfaceRow(
            "WiFi (wlp2s0)",
            wifiInterface['bytes_recv'],
            wifiInterface['bytes_sent'],
            wifiInterface['packets_recv'],
            wifiInterface['packets_sent'],
            wifiInterface['drop_in'] + wifiInterface['drop_out'],
          ),
          SizedBox(height: 8),

          _buildNetworkInterfaceRow(
            "Docker Bridge",
            dockerInterface['bytes_recv'],
            dockerInterface['bytes_sent'],
            dockerInterface['packets_recv'],
            dockerInterface['packets_sent'],
            dockerInterface['drop_in'] + dockerInterface['drop_out'],
          ),
          SizedBox(height: 20),

          // TCP Connections
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
                child: _buildNetworkStat(
                  "Established",
                  _telegrafData['network']['tcp_connections']['established']
                      .toString(),
                ),
              ),
              Expanded(
                child: _buildNetworkStat(
                  "Listening",
                  _telegrafData['network']['tcp_connections']['listen']
                      .toString(),
                ),
              ),
              Expanded(
                child: _buildNetworkStat(
                  "UDP Sockets",
                  _telegrafData['network']['udp_sockets'].toString(),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Docker Information
          Text(
            "Docker Status",
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
                child: _buildDockerStat(
                  "Containers",
                  "${dockerEngine['containers_running']}/${dockerEngine['containers_total']}",
                  "running/total",
                ),
              ),
              Expanded(
                child: _buildDockerStat(
                  "Images",
                  dockerEngine['images'].toString(),
                  "total",
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Pi-hole Container Details
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pi-hole Container",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        pihole['health'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "CPU: ${pihole['cpu_usage_percent'].toStringAsFixed(2)}%",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Memory: ${(pihole['memory_usage'] / (1024 * 1024)).toStringAsFixed(1)} MB",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "RX: ${(pihole['network_rx_bytes'] / (1024 * 1024)).toStringAsFixed(1)} MB",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "TX: ${(pihole['network_tx_bytes'] / (1024 * 1024)).toStringAsFixed(1)} MB",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkInterfaceRow(
    String name,
    int bytesRecv,
    int bytesSent,
    int packetsRecv,
    int packetsSent,
    int drops,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  "RX: ${(bytesRecv / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
              Expanded(
                child: Text(
                  "TX: ${(bytesSent / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Packets RX: ${(packetsRecv / 1000000).toStringAsFixed(1)}M",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
              Expanded(
                child: Text(
                  "Drops: $drops",
                  style: TextStyle(
                    fontSize: 12,
                    color: drops > 0 ? Colors.orange[600] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[600],
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDockerStat(String label, String value, String subtitle) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[600],
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
      ],
    );
  }

  Widget _buildAllDiskDevicesCard() {
    final disks = _telegrafData['disk'];

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
            "All Disk Devices",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          ...disks.entries
              .map((entry) => _buildDiskDeviceRow(entry.key, entry.value))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildDiskDeviceRow(String key, Map<String, dynamic> disk) {
    final sizeGB = disk['total'] / (1024 * 1024 * 1024);
    final usedGB = disk['used'] / (1024 * 1024 * 1024);
    final usagePercent = disk['used_percent'];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${disk['device']} (${disk['fstype']})",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      disk['path'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      sizeGB > 1
                          ? "${usedGB.toStringAsFixed(1)}/${sizeGB.toStringAsFixed(1)} GB"
                          : "${(disk['used'] / (1024 * 1024)).toStringAsFixed(1)}/${(disk['total'] / (1024 * 1024)).toStringAsFixed(1)} MB",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      "${usagePercent.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getUsageColor(usagePercent.round()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: usagePercent / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getUsageColor(usagePercent.round()),
            ),
            minHeight: 4,
          ),
          if (disk['inodes_total'] > 0) ...[
            SizedBox(height: 4),
            Text(
              "Inodes: ${disk['inodes_used']}/${disk['inodes_total']} (${disk['inodes_used_percent'].toStringAsFixed(1)}%)",
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }
}
