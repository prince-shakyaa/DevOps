project             = "campus-portal"
environment         = "dev"
vpc_cidr            = "10.40.0.0/16"
public_subnet_count = 2
web_instance_count  = 1
instance_type       = "t3.micro"
admin_cidr          = "198.51.100.24/32"
use_localstack      = true
