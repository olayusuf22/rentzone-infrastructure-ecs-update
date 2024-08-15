locals {
  region       = region
  project_name = project_name
  environment  = environment
}

# create vpc module
module "vpc" {
  source                       = "git@github.com:olayusuf22/terraform-modules-update.git//vpc"
  region                       = local.region
  project_name                 = local.project_name
  environment                  = local.environment
  vpc_cidr                     = vpc_cidr
  public_subnet_az1_cidr       = public_subnet_az1_cidr
  public_subnet_az2_cidr       = public_subnet_az2_cidr
  private_app_subnet_az1_cidr  = private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr  = private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr = private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = private_data_subnet_az2_cidr
}

# create nat-gateway
module "nat-gateway" {
  source                     = "git@github.com:olayusuf22/terraform-modules-update.git//nat-gateway"
  project_name               = local.project_name
  environment                = local.environment
  public_subnet_az1_id       = module.vpc.public_subnet_az1_id
  internet_gateway           = module.vpc.internet_gateway
  public_subnet_az2_id       = module.vpc.public_subnet_az2_id
  vpc_id                     = module.vpc.vpc_id
  private_app_subnet_az1_id  = module.vpc.private_app_subnet_az1_id
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_app_subnet_az2_id  = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id
}

# create security group
module "security-groups" {
  source       = "git@github.com:olayusuf22/terraform-modules-update.git//security-groups"
  project_name = local.project_name
  environment  = local.environment
  vpc_id       = module.vpc.vpc_id
  ssh_ip       = ssh_ip
}

# launch rds instance
module "rds" {
  source                       = "git@github.com:olayusuf22/terraform-modules-update.git//rds"
  project_name                 = local.project_name
  environment                  = local.environment
  private_data_subnet_az1_id   = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id   = module.vpc.private_data_subnet_az2_id
  database_snapshot_identifier = var.database_snapshot_identifier
  database_instance_class      = var.database_instance_class
  availability_zone_1          = module.vpc.availability_zone_1
  database_instance_indetifier = var.database_instance_identifier
  multi_az_deployment          = var.multi_az_deployment
  database_security_group_id   = module.security_groups.database_security_group_id
}