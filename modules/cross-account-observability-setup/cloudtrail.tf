resource "aws_cloudtrail" "cloudtrail_to_s3" {
  name                          = "cloudtrail-to-s3"
  s3_bucket_name                = var.cloud_trail_central_bucket
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"

      values = ["arn:aws:s3:::${var.cloud_trail_central_bucket}/"]
    }
  }
}