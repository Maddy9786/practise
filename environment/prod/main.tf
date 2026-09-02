module "rgs" {
  source = "../../module/azurerm_resource_group"
  rgs    = var.rgs
}


module "storage_account" {
  depends_on = [module.rgs]
  source     = "../../module/azurerm_storage_account"
  sta        = var.sta
}