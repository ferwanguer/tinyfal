from firebase_functions import firestore_fn, logger
from firebase_admin import firestore, messaging
from typing import Dict, Any

# Import our models functions
from models.models import extract_cpu_available_percent, extract_available_memory_percent

def send_cpu_threshold_notification(
    user_id: str, 
    resource_name: str, 
    current_cpu: float, 
    threshold: float, 
    fcm_token: str
) -> bool:
    """
    Sends a push notification when CPU usage falls below the specified threshold.
    
    Args:
        user_id: The user's unique identifier
        resource_name: The name of the resource being monitored
        current_cpu: Current CPU available percentage
        threshold: The threshold percentage that was breached
        fcm_token: Firebase Cloud Messaging token for the user's device
    
    Returns:
        bool: True if notification was sent successfully, False otherwise
    """
    try:
        # Create notification title and body
        title = f"⚠️ CPU Alert - {resource_name}"
        body = f"CPU available has dropped to {current_cpu:.1f}% (below {threshold:.1f}% threshold)"
        
        # Create the message
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data={
                'type': 'cpu_alert',
                'resource_name': resource_name,
                'current_cpu': str(current_cpu),
                'threshold': str(threshold),
                'user_id': user_id,
            },
            token=fcm_token,
        )
        
        # Send the message
        response = messaging.send(message)
        logger.info(f"CPU threshold notification sent successfully. Message ID: {response}")
        
        # Store notification in Firestore for history
        db = firestore.client()
        notification_data = {
            'title': title,
            'body': body,
            'timestamp': firestore.SERVER_TIMESTAMP,
            'type': 'cpu_alert',
            'resource_name': resource_name,
            'current_cpu': current_cpu,
            'threshold': threshold,
        }
        
        db.collection('users').document(user_id).collection('notifications').add(notification_data)
        logger.info(f"CPU alert notification stored in Firestore for user: {user_id}")
        
        return True
        
    except Exception as e:
        logger.error(f"Failed to send CPU threshold notification: {str(e)}")
        return False


def send_ram_threshold_notification(
    user_id: str, 
    resource_name: str, 
    current_ram: float, 
    threshold: float, 
    fcm_token: str
) -> bool:
    """
    Sends a push notification when RAM usage exceeds the specified threshold.
    
    Args:
        user_id: The user's unique identifier
        resource_name: The name of the resource being monitored
        current_ram: Current RAM usage percentage
        threshold: The threshold percentage that was breached
        fcm_token: Firebase Cloud Messaging token for the user's device
    
    Returns:
        bool: True if notification was sent successfully, False otherwise
    """
    try:
        # Create notification title and body
        title = f"🔴 RAM Alert - {resource_name}"
        body = f"RAM usage has reached {current_ram:.1f}% (above {threshold:.1f}% threshold)"
        
        # Create the message
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data={
                'type': 'ram_alert',
                'resource_name': resource_name,
                'current_ram': str(current_ram),
                'threshold': str(threshold),
                'user_id': user_id,
            },
            token=fcm_token,
        )
        
        # Send the message
        response = messaging.send(message)
        logger.info(f"RAM threshold notification sent successfully. Message ID: {response}")
        
        # Store notification in Firestore for history
        db = firestore.client()
        notification_data = {
            'title': title,
            'body': body,
            'timestamp': firestore.SERVER_TIMESTAMP,
            'type': 'ram_alert',
            'resource_name': resource_name,
            'current_ram': current_ram,
            'threshold': threshold,
        }
        
        db.collection('users').document(user_id).collection('notifications').add(notification_data)
        logger.info(f"RAM alert notification stored in Firestore for user: {user_id}")
        
        return True
        
    except Exception as e:
        logger.error(f"Failed to send RAM threshold notification: {str(e)}")
        return False


def check_and_send_threshold_alerts(
    user_id: str, 
    resource_id: str, 
    resource_name: str, 
    available_cpu_percent: int,
    available_memory_percent: int,
    user_settings: Dict[str, Any]
) -> None:
    """
    Checks resource metrics against user-defined thresholds and sends alerts if needed.
    
    Args:
        user_id: The user's unique identifier
        resource_id: The resource's unique identifier
        resource_name: The name of the resource being monitored
        available_cpu_percent: Already extracted CPU available percentage
        available_memory_percent: Already extracted memory available percentage
        user_settings: Dictionary containing user notification preferences
    """
    try:
        # Get user's FCM token
        fcm_token = user_settings.get('fcmToken')
        if not fcm_token:
            logger.warning(f"No FCM token found for user: {user_id}")
            return
        
        logger.info(f"Checking thresholds for user {user_id}, resource {resource_id} ({resource_name})")

        # Check if notifications are enabled
        notifications_enabled = user_settings.get('notificationsEnabled', True)
        if not notifications_enabled:
            logger.info(f"Notifications disabled for user: {user_id}")
            return
        
        # Check CPU threshold
        cpu_notifications_enabled = user_settings.get('cpuNotificationsEnabled', False)
        if cpu_notifications_enabled:
            cpu_threshold = user_settings.get('cpuThreshold', 10.0)  # Default 10%
            
            logger.info(f"CPU available: {available_cpu_percent}% for resource {resource_name}")
            
            if available_cpu_percent < cpu_threshold:
                logger.info(f"CPU threshold breached for resource {resource_name}: {available_cpu_percent}% < {cpu_threshold}%")
                send_cpu_threshold_notification(
                    user_id, resource_name, available_cpu_percent, cpu_threshold, fcm_token
                )
        
        # Check RAM threshold
        ram_notifications_enabled = user_settings.get('ramNotificationsEnabled', False)
        if ram_notifications_enabled:
            ram_threshold = user_settings.get('ramThreshold', 85.0)  # Default 85%
            
            # Convert available memory to usage percentage
            current_ram_usage = 100 - available_memory_percent
            logger.info(f"RAM usage: {current_ram_usage}% for resource {resource_name}")
            
            if current_ram_usage > ram_threshold:
                logger.info(f"RAM threshold breached for resource {resource_name}: {current_ram_usage}% > {ram_threshold}%")
                send_ram_threshold_notification(
                    user_id, resource_name, current_ram_usage, ram_threshold, fcm_token
                )
                
    except Exception as e:
        logger.error(f"Error checking thresholds for user {user_id}, resource {resource_id}: {str(e)}")
