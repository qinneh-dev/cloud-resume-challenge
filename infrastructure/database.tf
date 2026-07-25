resource "aws_dynamodb_table" "visitors_counter" {
    name           = "VisitorCount"
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "id"
    
    
    attribute {
        name = "id"
        type = "S"
    }
    
    point_in_time_recovery {
        enabled = false
    }
    
    server_side_encryption {
        enabled = true
    }
    
    deletion_protection_enabled = true
    
    tags = {
        Description = "DynamoDB table to store the number of visitors to the website"
    }
}

# seeding dynamodb
resource "aws_dynamodb_table_item" "seed_visitors_counter" {
    table_name = aws_dynamodb_table.visitors_counter.name
    hash_key   = aws_dynamodb_table.visitors_counter.hash_key
    
    item = <<EOF
    {
        "id": {"S": "resume"},
        "views": {"N": "0"}
    }
    EOF
    
    lifecycle {
        ignore_changes = [item]
    }
}