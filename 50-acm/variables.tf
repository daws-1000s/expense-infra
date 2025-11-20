variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "expense"
        Terraform = "true"
        Environment = "dev"
    }
}


variable "zone_name" {
    default = "daws100s.online"
}

variable "zone_id" {
    default = "Z0951733247NJS9XF1LII"
}
