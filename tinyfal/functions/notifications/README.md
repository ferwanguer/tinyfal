# Notification System

This document describes the notification system for monitoring CPU and RAM thresholds in TinyFal.

## Overview

The notification system monitors server metrics and sends push notifications to users when resource usage exceeds predefined thresholds. It consists of two main components:

1. **Python Backend Functions** - Handle the notification logic and Firebase Cloud Messaging
2. **Flutter Settings Widget** - Allows users to configure notification preferences

## Python Backend (`functions/notifications/notifications.py`)

### Key Functions

#### `send_cpu_threshold_notification()`
Sends a push notification when CPU available percentage drops below the user-defined threshold.

**Parameters:**
- `user_id`: User's unique identifier
- `resource_name`: Name of the monitored resource
- `current_cpu`: Current CPU available percentage
- `threshold`: Threshold percentage that was breached
- `fcm_token`: Firebase Cloud Messaging token

#### `send_ram_threshold_notification()`
Sends a push notification when RAM usage percentage exceeds the user-defined threshold.

**Parameters:**
- `user_id`: User's unique identifier
- `resource_name`: Name of the monitored resource
- `current_ram`: Current RAM usage percentage
- `threshold`: Threshold percentage that was breached
- `fcm_token`: Firebase Cloud Messaging token

#### `check_and_send_threshold_alerts()`
Main function that checks metrics against thresholds and triggers notifications. Includes rate limiting to prevent spam.

**Features:**
- Checks user notification preferences
- Validates FCM token
- Implements rate limiting
- Stores notification history in Firestore

## Flutter Settings Widget

The settings page now includes a comprehensive notification configuration section:

### Features

1. **General Notifications Toggle** - Master switch for all notifications
2. **CPU Alerts** - Toggle and threshold slider (1-50%)
3. **RAM Alerts** - Toggle and threshold slider (50-95%)
4. **Real-time Updates** - Changes are saved immediately to Firestore

### Default Settings

- **Notifications Enabled**: `true`
- **CPU Notifications**: `false` (user must opt-in)
- **RAM Notifications**: `false` (user must opt-in)
- **CPU Threshold**: `10%` (alert when available CPU drops below 10%)
- **RAM Threshold**: `85%` (alert when RAM usage exceeds 85%)

## Integration

The notification system is integrated into the main data ingestion flow (`functions/main.py`):

1. Data is received via the `ingest` function
2. After successful logging, `check_and_send_threshold_alerts()` is called
3. User preferences are retrieved from Firestore
4. Metrics are checked against thresholds
5. Notifications are sent if thresholds are breached

## Rate Limiting

To prevent notification spam:
- Notifications for the same resource and metric type are limited
- Minimum 60 seconds between notifications for the same resource
- Last alert timestamps are stored in Firestore

## Testing

A test function `test_notification` is available to manually trigger notifications:

```python
POST /test_notification
{
    "user_id": "user123",
    "type": "cpu"  // or "ram"
}
```

## Data Structure

### User Preferences (Firestore)
```json
{
    "notificationsEnabled": true,
    "cpuNotificationsEnabled": false,
    "ramNotificationsEnabled": false,
    "cpuThreshold": 10.0,
    "ramThreshold": 85.0,
    "fcmToken": "device_token_here"
}
```

### Notification History (Firestore)
```json
{
    "title": "⚠️ CPU Alert - Server Name",
    "body": "CPU available has dropped to 5.0% (below 10.0% threshold)",
    "timestamp": "2025-01-24T10:30:00Z",
    "type": "cpu_alert",
    "resource_name": "Server Name",
    "current_cpu": 5.0,
    "threshold": 10.0
}
```

### Rate Limiting Data (Firestore)
```json
{
    "timestamp": "2025-01-24T10:30:00Z",
    "value": 5.0
}
```

## Future Enhancements

1. **Multiple Threshold Levels** - Warning vs Critical alerts
2. **Custom Notification Schedules** - Quiet hours, etc.
3. **Email Notifications** - Alternative to push notifications
4. **Webhook Integration** - Send alerts to external systems
5. **Historical Analytics** - Track notification frequency and effectiveness
