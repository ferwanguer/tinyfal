# Testing the Notification System

This guide shows how to test the notification system you just implemented.

## Prerequisites

1. Make sure your Firebase Functions are deployed
2. Have a test user account in your app
3. The user should have notifications enabled in their device settings

## Step 1: Configure Notification Settings

1. Open the TinyFal app
2. Navigate to Settings
3. In the "Notification Settings" section:
   - Ensure "Enable Notifications" is ON
   - Enable either "CPU Alerts" or "RAM Alerts" (or both)
   - Adjust the thresholds as needed

## Step 2: Test with Manual Trigger

You can test the notification system by calling the test function:

```bash
# Test CPU notification
curl -X POST "https://your-region-your-project.cloudfunctions.net/test_notification" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "YOUR_USER_ID",
    "type": "cpu"
  }'

# Test RAM notification
curl -X POST "https://your-region-your-project.cloudfunctions.net/test_notification" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "YOUR_USER_ID", 
    "type": "ram"
  }'
```

Replace `YOUR_USER_ID` with the actual user ID from your app settings.

## Step 3: Test with Real Data

To test with actual server data, send metrics that breach your thresholds:

```bash
# Example: Send low CPU data to trigger CPU alert
curl -X POST "https://your-region-your-project.cloudfunctions.net/ingest" \
  -H "Authorization: Bearer YOUR_RESOURCE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cpu_available": 5.0,
    "ram_usage_percent": 60.0,
    "timestamp": "2025-01-24T10:30:00Z"
  }'

# Example: Send high RAM data to trigger RAM alert  
curl -X POST "https://your-region-your-project.cloudfunctions.net/ingest" \
  -H "Authorization: Bearer YOUR_RESOURCE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cpu_available": 80.0,
    "ram_usage_percent": 90.0,
    "timestamp": "2025-01-24T10:30:00Z"
  }'
```

## Step 4: Verify Notifications

After triggering a notification, you should:

1. **Receive a push notification** on your device
2. **See the notification in the app's Notifications tab**
3. **Check Firebase Console** for function logs

## Expected Notification Content

### CPU Alert
- **Title**: "⚠️ CPU Alert - [Resource Name]"
- **Body**: "CPU available has dropped to X.X% (below Y.Y% threshold)"

### RAM Alert
- **Title**: "🔴 RAM Alert - [Resource Name]"
- **Body**: "RAM usage has reached X.X% (above Y.Y% threshold)"

## Troubleshooting

### No notifications received:
1. Check if notifications are enabled in device settings
2. Verify FCM token exists in user preferences
3. Check Firebase Function logs for errors
4. Ensure thresholds are properly configured

### Notifications not appearing in app:
1. Check Firestore for notification documents
2. Verify the notification stream in the app
3. Check for any console errors in the app

### Rate limiting:
- Remember notifications are rate-limited to prevent spam
- Wait at least 60 seconds between tests for the same resource/metric

## Firebase Console Verification

Check these locations in Firebase Console:

1. **Functions Logs**: See if notifications are being sent
2. **Firestore**: 
   - `users/{userId}` - Check notification preferences
   - `users/{userId}/notifications` - Check notification history
   - `users/{userId}/last_alerts` - Check rate limiting data
3. **Cloud Messaging**: Monitor message delivery statistics
