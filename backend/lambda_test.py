import importlib
import os
import json
import pytest
import boto3
from botocore.exceptions import ClientError 
from moto import mock_aws

#setting up env vars for testing before importing the function
os.environ['AWS_ACCESS_KEY_ID'] = 'testing'
os.environ['AWS_SECRET_ACCESS_KEY'] = 'testing'
os.environ['AWS_SECURITY_TOKEN'] = 'testing'
os.environ['AWS_SESSION_TOKEN'] = 'testing'
os.environ['AWS_DEFAULT_REGION'] = 'eu-central-1'
os.environ['AWS_REGION'] = 'eu-central-1'

import lambda_function


@pytest.fixture #temp database environment
def dynamodb_setup():
    with mock_aws():
        # Create a fake dynamodb connection
        dynamodb = boto3.resource('dynamodb', region_name='eu-central-1')
        
    # Create fake table 
        table = dynamodb.create_table(
            TableName='VisitorCount',
            KeySchema=[{'AttributeName': 'id', 'KeyType': 'HASH'}],
            AttributeDefinitions=[{'AttributeName': 'id', 'AttributeType': 'S'}],
            BillingMode='PAY_PER_REQUEST'
        )
        table.put_item(Item={'id': 'resume', 'views': 0})
        importlib.reload(lambda_function)
        yield table



def test_handler_returns_200_and_cors(dynamodb_setup):
    """Verifies the HTTP status code and CORS headers are correct."""
    
    response = lambda_function.lambda_handler({}, {})
    
    assert response['statusCode'] == 200
    assert response['headers']['Access-Control-Allow-Origin'] == '*'

def test_handler_increments_value_by_one(dynamodb_setup):
    """Verifies that calling the function atomically increments the counter"""
    
    response_one = lambda_function.lambda_handler({}, {})
    body_one = json.loads(response_one['body'])
    
    # started  at 0 so  should return 1
    assert body_one['views'] == 1
    
    # Calling 2nd time
    response_two = lambda_function.lambda_handler({}, {})
    body_two = json.loads(response_two['body'])
    
    # The second call should return 2
    assert body_two['views'] == 2



def test_response_body_contains_views_as_integer(dynamodb_setup):
    """
    Verifies that the returned json body contains the correct key ('views') 
    and that the data type is int
    """
    response = lambda_function.lambda_handler({}, {})
    body = json.loads(response['body'])
    
    assert 'views' in body
    
    assert isinstance(body['views'], int)


def test_database_is_updated_correctly(dynamodb_setup):
    """
    Verifies that the dynamodb table is physically updated. 
    """
    lambda_function.lambda_handler({}, {})
    
    response = dynamodb_setup.get_item(Key={'id': 'resume'})
    actual_db_item = response.get('Item')
    
    assert actual_db_item is not None
    assert actual_db_item['views'] == 1


def test_empty_table_initializes_at_one(dynamodb_setup):
    """
    Verifies the resilience of the ADD command. If someone accidentally deletes 
    the 'resume' item from your database, DynamoDB's ADD command acts as an 'Upsert' 
    (Update or Insert). It should automatically recreate the item and set it to 1.
    """
    #  Manually delete the resume item from our fake database
    dynamodb_setup.delete_item(Key={'id': 'resume'})
    
    # Trigger the lambda against the missing item
    response = lambda_function.lambda_handler({}, {})
    body = json.loads(response['body'])
    
    #  Ensure the function didn't crash and started counting at 1
    assert body['views'] == 1


def test_database_error_propagates():
    """
    Verifies that if the database is completely missing (e.g., you accidentally delete 
    the whole table, or IAM permissions break), the Lambda function fails loudly with 
    a ClientError rather than failing silently.
    """
    with mock_aws():
        
        # Reload the function so it connects to this empty, broken mock environment
        importlib.reload(lambda_function)
    
        with pytest.raises(ClientError):
            lambda_function.lambda_handler({}, {})