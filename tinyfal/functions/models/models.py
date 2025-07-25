"""
Models for processing resource data similar to resource.dart
"""
import math
from typing import List, Dict, Any, Optional
from firebase_functions import logger


def get_by_name(data: List[Dict[str, Any]], name: str) -> List[Dict[str, Any]]:
    """
    Get all maps with a given 'name' attribute
    
    Args:
        data: List of dictionaries containing resource metrics data
        name: The name to filter by
        
    Returns:
        List of dictionaries matching the name
    """
    return [item for item in data if item.get('name') == name]


def get_mem_data(data: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    """
    Get memory data entry
    
    Args:
        data: List of dictionaries containing resource metrics data
        
    Returns:
        Memory data dictionary or None if not found
    """
    mem_list = get_by_name(data, 'mem')
    return mem_list[0] if mem_list else None


def get_cpu_total_data(data: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    """
    Get CPU total data entry (cpu-total)
    
    Args:
        data: List of dictionaries containing resource metrics data
        
    Returns:
        CPU total data dictionary or None if not found
    """
    cpu_list = get_by_name(data, 'cpu')
    # Look for the cpu-total entry specifically
    for cpu in cpu_list:
        tags = cpu.get('tags', {})
        if tags.get('cpu') == 'cpu-total':
            return cpu
    return None


def extract_available_memory_percent(data: List[Dict[str, Any]]) -> Optional[int]:
    """
    Extract available memory percentage from resource data (equivalent to availableMemoryPercent in Dart)
    
    Args:
        data: List of resource metric dictionaries
        
    Returns:
        Available memory percentage as integer (rounded up) or None if not available
    """
    logger.info(f"Extracting available memory percent from data with {len(data)} entries")
    
    mem_data = get_mem_data(data)
    if mem_data is None:
        logger.warn("No memory data found in resource metrics")
        return None
    
    fields = mem_data.get('fields', {})
    if not fields:
        logger.warn("No fields found in memory data")
        return None
    
    available_percent = fields.get('available_percent')
    if available_percent is None:
        logger.warn("available_percent field not found in memory data fields")
        return None
    
    # Convert to number and round up (ceiling)
    if isinstance(available_percent, (int, float)):
        result = math.ceil(float(available_percent))
        logger.info(f"Successfully extracted available memory percent: {result}%")
        return result
    else:
        logger.error(f"available_percent is not a number: {type(available_percent).__name__} = {available_percent}")
    
    return None


def extract_cpu_usage_percent(data: List[Dict[str, Any]]) -> Optional[int]:
    """
    Extract CPU usage percentage from resource data (calculated as: 100 - idle_usage)
    
    Args:
        data: List of resource metric dictionaries
        
    Returns:
        CPU usage percentage as integer (rounded up) or None if not available
    """
    cpu_data = get_cpu_total_data(data)
    if cpu_data is None:
        return None
    
    fields = cpu_data.get('fields', {})
    if not fields:
        return None
    
    idle_usage = fields.get('usage_idle')
    if idle_usage is None:
        return None
    
    if isinstance(idle_usage, (int, float)):
        used_percent = 100.0 - float(idle_usage)
        result = math.ceil(used_percent)
        # Clamp between 0 and 100
        result = max(0, min(100, result))
        
        # Handle anomalous 0% readings (similar to Dart logic)
        if result == 0:
            # In a real implementation, you might want to check timestamp
            # For now, we'll just return the result
            pass
        
        return result
    
    return None


def extract_cpu_available_percent(data: List[Dict[str, Any]]) -> Optional[int]:
    """
    Extract available CPU percentage from resource data (calculated as: 100 - cpu_usage)
    This is the inverse of CPU usage, representing available CPU capacity
    
    Args:
        data: List of resource metric dictionaries
        
    Returns:
        Available CPU percentage as integer or None if not available
    """
    cpu_usage = extract_cpu_usage_percent(data)
    if cpu_usage is None:
        return None
    
    # Available CPU is the inverse of used CPU
    cpu_available = 100 - cpu_usage
    return max(0, min(100, cpu_available))



    



