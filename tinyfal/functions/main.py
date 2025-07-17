# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import https_fn, logger
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, firestore
import json
from datetime import datetime, timezone

# For cost control, you can set the maximum number of containers that can be
# running at the same time. This helps mitigate the impact of unexpected
# traffic spikes by instead downgrading performance. This limit is a per-function
# limit. You can override the limit for each function using the max_instances
# parameter in the decorator, e.g. @https_fn.on_request(max_instances=5).
set_global_options(max_instances=10)

# Initialize Firebase Admin SDK
initialize_app()


@https_fn.on_request()
def ingest(req: https_fn.Request) -> https_fn.Response:
    """
    Firebase function that handles POST requests with authorization tokens.
    Logs JSON data to the corresponding user's resource document.
    """
    
    db = firestore.client()
    
    # Only allow POST requests
    if req.method != 'POST':
        return https_fn.Response(
            json.dumps({"error": "Only POST requests are allowed"}),
            status=405,
            headers={"Content-Type": "application/json"}
        )
    
    # Get authorization token from headers
    auth_header = req.headers.get('Authorization')
    if not auth_header:
        return https_fn.Response(
            json.dumps({"error": "Authorization header is required"}),
            status=401,
            headers={"Content-Type": "application/json"}
        )
    
    # Extract token from "Bearer <token>" format
    try:
        if not auth_header.startswith('Bearer '):
            raise ValueError("Invalid authorization format")
        token = auth_header.split('Bearer ')[1]
    except (IndexError, ValueError):
        return https_fn.Response(
            json.dumps({"error": "Invalid authorization format. Use 'Bearer <token>'"}),
            status=401,
            headers={"Content-Type": "application/json"}
        )
    
    # Find the user and resource that corresponds to this token using collection group query
    try:
        # Use collection group query to search across all 'resources' subcollections
        resources_query = db.collection_group('resources').where('token', '==', token).limit(1)
        resources_docs = list(resources_query.stream())
        
        if not resources_docs:
            return https_fn.Response(
                json.dumps({"error": "Invalid or unauthorized token"}),
                status=401,
                headers={"Content-Type": "application/json"}
            )
        
        # Extract user_id and resource_id from the document path
        resource_doc = resources_docs[0]
        resource_id = resource_doc.id
        
        # The document path format is: users/{user_id}/resources/{resource_id}
        # So we can extract user_id from the parent reference
        user_id = resource_doc.reference.parent.parent.id
            
    except Exception as e:
        logger.error(f"Token verification failed for token: {token[:10]}... Error: {str(e)}")
        
        return https_fn.Response(
            json.dumps({"error": f"Token verification failed: {str(e)}"}),
            status=401,
            headers={"Content-Type": "application/json"}
        )
    # Log successful token verification
    logger.info(f"Token verified successfully for user_id: {user_id}, resource_id: {resource_id}")

    # Parse JSON body
    try:
        request_data = req.get_json()
        if request_data is None:
            return https_fn.Response(
                json.dumps({"error": "Request body must be valid JSON"}),
                status=400,
                headers={"Content-Type": "application/json"}
            )
    except Exception as e:
        return https_fn.Response(
            json.dumps({"error": f"Invalid JSON: {str(e)}"}),
            status=400,
            headers={"Content-Type": "application/json"}
        )
    
    # user_id and resource_id are already determined from token lookup above
    # Create document path
    doc_path = f"users/{user_id}/resources/{resource_id}"
    
    # Get current server time at the beginning of function execution
    current_time = datetime.now(timezone.utc)
    
    # Log data to Firestore
    try:
        # Get reference to the document
        doc_ref = db.document(doc_path)
        
        # Check if document exists and get the last_update timestamp
        doc_snapshot = doc_ref.get()
        
        if doc_snapshot.exists:
            doc_data = doc_snapshot.to_dict()
            last_update = doc_data.get('last_update')
            
            if last_update:
                # Calculate time difference in seconds
                time_diff = (current_time - last_update).total_seconds()
                
                # If last update was within 60 seconds, don't update
                if time_diff < 60:
                    logger.info(f"Data received but not logged for user_id: {user_id}, resource_id: {resource_id}. Last update was {time_diff:.1f} seconds ago (less than 60 seconds)")
                    
                    return https_fn.Response(
                        json.dumps({
                            "success": True,
                            "message": "Data received but not logged (last update was less than 60 seconds ago)",
                        }),
                        status=200,
                        headers={"Content-Type": "application/json"}
                    )
        
        # Set the entry data with merge capabilities
        doc_ref.set(request_data, merge=True)
        
        # Log the last_update timestamp
        doc_ref.set({"last_update": firestore.SERVER_TIMESTAMP}, merge=True)
        
        # Log successful data logging
        logger.info(f"Data logged successfully for user_id: {user_id}, resource_id: {resource_id}")
        
        return https_fn.Response(
            json.dumps({
                "success": True, 
                "message": "Data logged successfully",
                "document_path": doc_path,
                "user_id": user_id,
                "resource_id": resource_id
            }),
            status=200,
            headers={"Content-Type": "application/json"}
        )
        
    except Exception as e:
        logger.error(f"Failed to log data for user_id: {user_id}, resource_id: {resource_id}. Error: {str(e)}")
        return https_fn.Response(
            json.dumps({"error": f"Failed to log data: {str(e)}"}),
            status=500,
            headers={"Content-Type": "application/json"}
        ) 

# @https_fn.on_request()
# def on_request_example(req: https_fn.Request) -> https_fn.Response:
#     return https_fn.Response("Hello world!")