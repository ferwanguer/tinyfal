# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import https_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app, firestore
import json

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
        return https_fn.Response(
            json.dumps({"error": f"Token verification failed: {str(e)}"}),
            status=401,
            headers={"Content-Type": "application/json"}
        )
    
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
    
    # Prepare data to log with timestamp
    log_entry = {
        "data": request_data,
        "timestamp": firestore.SERVER_TIMESTAMP,
        "user_id": user_id,
        "resource_id": resource_id
    }
    
    # Log data to Firestore
    try:
        # Get reference to the document
        doc_ref = db.document(doc_path)
        
        # Add the log entry to a subcollection for historical records
        logs_collection = doc_ref.collection('logs')
        logs_collection.add(log_entry)
        
        # Update the main document with latest data
        # doc_ref.set({
        #     "latest_data": request_data,
        #     "last_updated": firestore.SERVER_TIMESTAMP,
        #     "user_id": user_id,
        #     "resource_id": resource_id
        # }, merge=True)
        
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
        return https_fn.Response(
            json.dumps({"error": f"Failed to log data: {str(e)}"}),
            status=500,
            headers={"Content-Type": "application/json"}
        )


# @https_fn.on_request()
# def on_request_example(req: https_fn.Request) -> https_fn.Response:
#     return https_fn.Response("Hello world!")