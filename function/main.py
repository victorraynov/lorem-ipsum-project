"""
VPC Inventory Cloud Function
Lists all VPCs and Subnets in the GCP project and saves to Firestore
"""

import functions_framework
from google.cloud import compute_v1
from google.cloud import firestore
from datetime import datetime
import os


def get_project_id():
    """Get the GCP project ID from environment"""
    return os.environ.get('GCP_PROJECT')


def list_vpcs(project_id):
    """
    List all VPCs (networks) in the project
    
    Returns:
        list: List of VPC dictionaries with details
    """
    client = compute_v1.NetworksClient()
    
    vpcs = []
    request = compute_v1.ListNetworksRequest(project=project_id)
    
    for network in client.list(request=request):
        vpc_data = {
            'id': str(network.id),
            'name': network.name,
            'description': network.description if network.description else '',
            'auto_create_subnetworks': network.auto_create_subnetworks,
            'routing_mode': network.routing_config.routing_mode if network.routing_config else 'REGIONAL',
            'mtu': network.mtu if network.mtu else 1460,
            'self_link': network.self_link,
            'creation_timestamp': network.creation_timestamp
        }
        vpcs.append(vpc_data)
    
    return vpcs


def list_subnets(project_id):
    """
    List all subnets across all regions in the project
    
    Returns:
        list: List of subnet dictionaries with details
    """
    client = compute_v1.SubnetworksClient()
    
    subnets = []
    
    regions_client = compute_v1.RegionsClient()
    regions_request = compute_v1.ListRegionsRequest(project=project_id)
    
    for region in regions_client.list(request=regions_request):
        region_name = region.name
        
        subnets_request = compute_v1.ListSubnetworksRequest(
            project=project_id,
            region=region_name
        )
        
        for subnet in client.list(request=subnets_request):
            subnet_data = {
                'id': str(subnet.id),
                'name': subnet.name,
                'region': region_name,
                'network': subnet.network.split('/')[-1],
                'ip_cidr_range': subnet.ip_cidr_range,
                'gateway_address': subnet.gateway_address,
                'private_ip_google_access': subnet.private_ip_google_access,
                'enable_flow_logs': subnet.enable_flow_logs if hasattr(subnet, 'enable_flow_logs') else False,
                'purpose': subnet.purpose if subnet.purpose else 'PRIVATE',
                'self_link': subnet.self_link,
                'creation_timestamp': subnet.creation_timestamp
            }
            
            if subnet.secondary_ip_ranges:
                subnet_data['secondary_ranges'] = [
                    {
                        'range_name': r.range_name,
                        'ip_cidr_range': r.ip_cidr_range
                    }
                    for r in subnet.secondary_ip_ranges
                ]
            
            subnets.append(subnet_data)
    
    return subnets


def save_to_firestore(vpcs, subnets):
    """
    Save VPC and subnet data to Firestore
    """
    db = firestore.Client(database='vpc-inventory-db')

    timestamp = datetime.utcnow()
    inventory_id = timestamp.strftime('%Y%m%d_%H%M%S')
    
    inventory_ref = db.collection('vpc_inventories').document(inventory_id)
    inventory_ref.set({
        'timestamp': timestamp,
        'vpc_count': len(vpcs),
        'subnet_count': len(subnets),
        'status': 'completed'
    })
    
    vpcs_collection = inventory_ref.collection('vpcs')
    for vpc in vpcs:
        vpc_ref = vpcs_collection.document(vpc['name'])
        vpc_ref.set(vpc)
    
    subnets_collection = inventory_ref.collection('subnets')
    for subnet in subnets:
        subnet_ref = subnets_collection.document(f"{subnet['region']}_{subnet['name']}")
        subnet_ref.set(subnet)
    
    return inventory_id


@functions_framework.http
def vpc_inventory(request):
    """
    HTTP Cloud Function to inventory VPCs and Subnets
    """
    try:
        project_id = get_project_id()
        
        if not project_id:
            return {'error': 'GCP_PROJECT environment variable not set'}, 500
        
        print(f"Starting VPC inventory for project: {project_id}")
        vpcs = list_vpcs(project_id)
        print(f"Found {len(vpcs)} VPCs")
        
        subnets = list_subnets(project_id)
        print(f"Found {len(subnets)} subnets")
        
        inventory_id = save_to_firestore(vpcs, subnets)
        print(f"Saved inventory with ID: {inventory_id}")
        
        response = {
            'status': 'success',
            'inventory_id': inventory_id,
            'timestamp': datetime.utcnow().isoformat(),
            'summary': {
                'project_id': project_id,
                'vpc_count': len(vpcs),
                'subnet_count': len(subnets),
                'vpcs': [{'name': v['name'], 'id': v['id']} for v in vpcs],
                'subnets_by_vpc': {}
            }
        }
        
        for subnet in subnets:
            vpc_name = subnet['network']
            if vpc_name not in response['summary']['subnets_by_vpc']:
                response['summary']['subnets_by_vpc'][vpc_name] = []
            response['summary']['subnets_by_vpc'][vpc_name].append({
                'name': subnet['name'],
                'region': subnet['region'],
                'cidr': subnet['ip_cidr_range']
            })
        
        return response, 200
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {'status': 'error', 'error': str(e)}, 500
