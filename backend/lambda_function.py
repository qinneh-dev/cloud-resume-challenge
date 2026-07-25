import json 
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('VisitorCount')
#atomic update, doesnt use GetItem and PutItem, instead uses UpdateItem
def lambda_handler(event, context): 
    # increments by 1
    response = table.update_item(
        Key={'id': 'resume'},
        UpdateExpression='ADD #v :inc',
        ExpressionAttributeNames={'#v': 'views'},
        ExpressionAttributeValues={':inc': 1},
        ReturnValues="UPDATED_NEW"
    )    
    views = int(response['Attributes']['views'])
    return {
    'statusCode': 200,
    'headers':{ #CORS headers
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'

    },
    'body': json.dumps({'views': views})
}