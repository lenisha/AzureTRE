data "azurerm_storage_share" "shared_storage" {
  name                 = local.shared_storage_share
  storage_account_name = local.storage_name
}

resource "azurerm_app_service" "mlflow" {
  name                = local.webapp_name
  location            = data.azurerm_resource_group.ws.location
  resource_group_name = data.azurerm_resource_group.ws.name
  app_service_plan_id = data.azurerm_app_service_plan.workspace.id
  https_only          = true
  #vnet_route_all_enabled = true

  site_config {
    linux_fx_version                     = "DOCKER|${data.azurerm_container_registry.mgmt_acr.login_server}/microsoft/azuretre/${var.image_name}:${var.image_tag}"
    http2_enabled                        = true
    acr_use_managed_identity_credentials = true
  }

  app_settings = {
    WEBSITE_DNS_SERVER     = "168.63.129.16"
    WEBSITE_VNET_ROUTE_ALL = "1"

    MLFLOW_SERVER_WORKERS = "1"
    MLFLOW_SERVER_PORT    = "5000"
    MLFLOW_SERVER_HOST    = "0.0.0.0"

    MLFLOW_SERVER_FILE_STORE            = format("%s%s%s%s%s%s%s%s%s%s", "postgresql://", random_string.username.result, "@", azurerm_postgresql_server.mlflow.name, ":", random_password.password.result, "@", azurerm_postgresql_server.mlflow.name, ".postgres.database.azure.com:5432/", azurerm_postgresql_database.mlflow.name)
    MLFLOW_SERVER_DEFAULT_ARTIFACT_ROOT = format("%s%s%s%s%s", "wasbs://", data.azurerm_storage_share.shared_storage.name, "@", data.azurerm_storage_account.mlflow.name, ".blob.core.windows.net/mlartefacts")
    AZURE_STORAGE_CONNECTION_STRING     = data.azurerm_storage_account.mlflow.primary_connection_string
  }

  storage_account {
    name         = "mlflow-data"
    type         = "AzureFiles"
    account_name = data.azurerm_storage_account.mlflow.name

    access_key = data.azurerm_storage_account.mlflow.primary_access_key
    share_name = data.azurerm_storage_share.shared_storage.name
    mount_path = "/mlartefacts"
  }

  logs {
    application_logs {
      file_system_level = "Information"
    }

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_monitor_diagnostic_setting" "mlflow" {
  name                       = "diag-${var.tre_id}"
  target_resource_id         = azurerm_app_service.mlflow.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.tre.id

  log {
    category = "AppServiceHTTPLogs"
    enabled  = true

    retention_policy {
      days    = 1
      enabled = false
    }
  }

  log {
    category = "AppServiceConsoleLogs"
    enabled  = true

    retention_policy {
      days    = 1
      enabled = false
    }
  }

  log {
    category = "AppServiceAppLogs"
    enabled  = true

    retention_policy {
      days    = 1
      enabled = false
    }
  }

  log {
    category = "AppServiceFileAuditLogs"
    enabled  = true

    retention_policy {
      days    = 1
      enabled = false
    }
  }

  log {
    category = "AppServiceAuditLogs"
    enabled  = true

    retention_policy {
      days    = 1
      enabled = false
    }
  }

  log {
    category = "AppServiceIPSecAuditLogs"
    enabled  = true

    retention_policy {
      days    = 1
      enabled = false
    }
  }

  log {
    category = "AppServicePlatformLogs"
    enabled  = true

    retention_policy {
      days    = 1
      enabled = false
    }
  }

  log {
    category = "AppServiceAntivirusScanAuditLogs"
    enabled  = true

    retention_policy {
      days    = 1
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_role_assignment" "mlflow_acr_pull" {
  scope                = data.azurerm_container_registry.mgmt_acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_app_service.mlflow.identity[0].principal_id
}

resource "azurerm_app_service_virtual_network_swift_connection" "mlflow" {
  app_service_id = azurerm_app_service.mlflow.id
  subnet_id      = data.azurerm_subnet.web_apps.id
}

resource "azurerm_private_endpoint" "mlflow" {
  # disabling this makes the webapp available on the public internet
  count = var.is_exposed_externally == false ? 1 : 0

  name                = "pe-${local.webapp_name}"
  location            = data.azurerm_resource_group.ws.location
  resource_group_name = data.azurerm_resource_group.ws.name
  subnet_id           = data.azurerm_subnet.services.id

  private_service_connection {
    private_connection_resource_id = azurerm_app_service.mlflow.id
    name                           = "psc-${local.webapp_name}"
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatelink.azurewebsites.net"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.azurewebsites.id]
  }
}

resource "azurerm_key_vault_access_policy" "mlflow" {
  key_vault_id = data.azurerm_key_vault.ws.id
  tenant_id    = azurerm_app_service.mlflow.identity[0].tenant_id
  object_id    = azurerm_app_service.mlflow.identity[0].principal_id

  secret_permissions = ["Get", "List", ]
}
