# reference documentation https://grafana.com/docs/agent/latest/flow/reference/components/prometheus.exporter.cloudwatch/

serviceAccount:
  create: true
  name: ${exporter_name}
  annotations:
    eks.amazonaws.com/role-arn: ${role_arn}

agent:
  mode: 'flow'
  configMap:
    create: true
    content: |
      prometheus.remote_write "prometheus" {
        endpoint {
            url = "${mimir_load_balancer}"
        }
      }
      prometheus.scrape "scrape" {
        targets    = prometheus.exporter.cloudwatch.export_cloudwatch.targets
        forward_to = [prometheus.remote_write.prometheus.receiver]
      }
      
      prometheus.exporter.cloudwatch "export_cloudwatch" {
      
        sts_region = "${region}"
      
        decoupled_scraping {
          enabled = true
          scrape_interval = "${scrape_interval}m"
        }
      
        %{ for account_id in account_id_list ~}
        discovery {
          type = "AWS/Lambda"
          regions = ["${region}"]
               
          role {
            role_arn = "arn:aws:iam::${account_id}:role/grafana-agent-role"
          }
      
          metric {
            name       = "Invocations"
            statistics = ["Sum", "Average"]
            period     = "1m"
          }
          metric {
            name       = "Duration"
            statistics = ["Average", "Maximum"]
            period     = "1m"
          }
          metric {
            name       = "Errors"
            statistics = ["Sum"]
            period     = "1m"
          }
          metric {
            name       = "Throttles"
            statistics = ["Sum"]
            period     = "1m"
          }
          metric {
            name       = "IteratorAge"
            statistics = ["Average"]
            period     = "1m"
          }
          metric {
            name       = "DeadLetterErrors"
            statistics = ["Sum"]
            period     = "1m"
          }
          metric {
            name       = "ConcurrentExecutions"
            statistics = ["Maximum"]
            period     = "1m"
          }
          metric {
            name       = "UnreservedConcurrentExecutions"
            statistics = ["Maximum"]
            period     = "1m"
          }
          metric {
            name       = "ProvisionedConcurrencyInvocations"
            statistics = ["Sum"]
            period     = "1m"
          }
          metric {
            name       = "ProvisionedConcurrencySpilloverInvocations"
            statistics = ["Sum"]
            period     = "1m"
          }
          metric {
            name       = "ProvisionedConcurrencyUtilization"
            statistics = ["Maximum"]
            period     = "1m"
          }
        }
        %{ endfor ~}
      
        %{ for account_id in account_id_list ~}
        discovery {
          type = "ec2"
          regions = ["${region}"]
      
          role {
            role_arn = "arn:aws:iam::${account_id}:role/grafana-agent-role"
          }
      
          metric {
            name       = "CPUUtilization"
            statistics = ["Average", "Maximum", "Minimum"]
            period     = "1m"
          }

          metric {
            name       = "NetworkIn"
            statistics = ["Sum", "Average"]
            period     = "1m"
          }

          metric {
            name       = "NetworkOut"
            statistics = ["Sum", "Average"]
            period     = "1m"
          }

          metric {
            name       = "DiskReadOps"
            statistics = ["Sum", "Average"]
            period     = "1m"
          }

          metric {
            name       = "DiskWriteOps"
            statistics = ["Sum", "Average"]
            period     = "1m"
          }

          metric {
            name       = "DiskReadBytes"
            statistics = ["Sum", "Average"]
            period     = "1m"
          }

          metric {
            name       = "DiskWriteBytes"
            statistics = ["Sum", "Average"]
            period     = "1m"
          }

          metric {
            name       = "StatusCheckFailed"
            statistics = ["Sum"]
            period     = "1m"
          }

          metric {
            name       = "StatusCheckFailed_Instance"
            statistics = ["Sum"]
            period     = "1m"
          }

          metric {
            name       = "StatusCheckFailed_System"
            statistics = ["Sum"]
            period     = "1m"
          }
        }
        %{ endfor ~}

        %{ for account_id in account_id_list ~}
        discovery {
          type = "alb"
          regions = ["${region}"]
      
          role {
            role_arn = "arn:aws:iam::${account_id}:role/grafana-agent-role"
          }
      
          metric {
            name       = "RequestCount"
            statistics = ["Sum", "Average"]
            period     = "1m"
          }
            
          metric {
            name       = "HTTPCode_Target_2XX_Count"
            statistics = ["Sum"]
            period     = "1m"
          }
            
          metric {
            name       = "HTTPCode_Target_3XX_Count"
            statistics = ["Sum"]
            period     = "1m"
          }
            
          metric {
            name       = "HTTPCode_Target_4XX_Count"
            statistics = ["Sum"]
            period     = "1m"
          }
            
          metric {
            name       = "HTTPCode_Target_5XX_Count"
            statistics = ["Sum"]
            period     = "1m"
          }
            
          metric {
            name       = "TargetResponseTime"
            statistics = ["Average", "Maximum"]
            period     = "1m"
          }
            
          metric {
            name       = "HealthyHostCount"
            statistics = ["Minimum"]
            period     = "1m"
          }
            
          metric {
            name       = "UnHealthyHostCount"
            statistics = ["Maximum"]
            period     = "1m"
          }
            
          metric {
            name       = "ActiveConnectionCount"
            statistics = ["Sum", "Average"]
            period     = "1m"
          }
            
          metric {
            name       = "NewConnectionCount"
            statistics = ["Sum"]
            period     = "1m"
          }
            
          metric {
            name       = "ProcessedBytes"
            statistics = ["Sum"]
            period     = "1m"
          }
            
          metric {
            name       = "SurgeQueueLength"
            statistics = ["Maximum"]
            period     = "1m"
          }
            
          metric {
            name       = "SpilloverCount"
            statistics = ["Sum"]
            period     = "1m"
          }
        }
        %{ endfor ~}
      }