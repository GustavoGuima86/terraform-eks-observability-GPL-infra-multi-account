# resource "aws_cloudtrail" "cloudtrail_to_s3" {
#   name                          = "cloudtrail-to-s3"
#   s3_bucket_name                = aws_s3_bucket.cloud_trail_s3_bucket.bucket
#   include_global_service_events = true
#   is_multi_region_trail         = false
#   enable_logging                = true
#
#   event_selector {
#     read_write_type           = "All"
#     include_management_events = true
#
#     data_resource {
#       type = "AWS::S3::Object"
#
#       values = ["arn:aws:s3:::${aws_s3_bucket.cloud_trail_s3_bucket.bucket}/"]
#     }
#   }
# }