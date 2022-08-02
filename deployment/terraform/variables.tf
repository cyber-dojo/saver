variable "service_name" {
  type = string
  default = "saver"
}

variable "env" {
  type = string
}

variable "app_port" {
  type = number
  default = 4537
}

variable "cpu_limit" {
  type = number
  default = 50
}

variable "mem_limit" {
  type = number
  default = 256
}

variable "mem_reservation" {
  type = number
  default = 128
}

variable "TAGGED_IMAGE" {
  type = string
}

# App variables
variable "app_env_vars" {
  type = map(any)
  default = {
    CYBER_DOJO_PROMETHEUS                      = "false"
    CYBER_DOJO_SAVER_PORT                      = "4537"
    CYBER_DOJO_LANGUAGES_START_POINTS_PORT     = "4524"
    CYBER_DOJO_EXERCISES_START_POINTS_PORT     = "4525"
    CYBER_DOJO_CUSTOM_START_POINTS_PORT        = "4526"
    CYBER_DOJO_LANGUAGES_START_POINTS_HOSTNAME = "languages-start-points.cyber-dojo.eu-central-1"
    CYBER_DOJO_EXERCISES_START_POINTS_HOSTNAME = "exercises-start-points.cyber-dojo.eu-central-1"
    CYBER_DOJO_CUSTOM_START_POINTS_HOSTNAME    = "custom-start-points.cyber-dojo.eu-central-1"
  }
}

variable "ecr_replication_targets" {
  type    = list(map(string))
  default = []
}

variable "ecr_replication_origin" {
  type    = string
  default = ""
}
