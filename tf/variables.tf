variable "location" {
  type    = string
  default = "westeurope"
}
variable "naming-suffix" {
  type    = string
  default = "nvidia-desktop-demo"
}
variable "source_image_id" {
    type = string
    default = "/subscriptions/5305c27d-8d75-4340-9c62-4a7e98d498b4/resourceGroups/rg-shared-dev/providers/Microsoft.Compute/images/ubuntu18.04-desktop-nvidia-template-20200521195202"
}
# variable "admin_password" {
#     type = string
#     default = "asdklfjwero43_56"
# }

