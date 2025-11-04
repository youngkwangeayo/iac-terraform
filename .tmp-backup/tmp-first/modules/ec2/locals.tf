
locals {

  ami_type = {
    
    "ubuntu"           = "ami-00e73adb2e2c80366"
    "deeplearning_ubuntu_cuda" = "ami-0ff6207cd3439058e"
    "amazon_linux"     = "ami-07395584aac007ad4"
    
    
    # "default_ubuntu" = {
    #   "ami"   = "ami-00e73adb2e2c80366"
    #   "filter" = "**"
    # }
    # "deeplearning_ubuntu_cuda" = {
    #   "ami"   = "ami-0ff6207cd3439058e"
    #   "filter" = "**"
    # }
    # "default_amazon_linux" = {
    #   ami   = "ami-07395584aac007ad4"
    #   filter = "al2023-ami-*-x86_64"
    # }
  }

}
