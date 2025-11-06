variable "zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
}

variable "name" {
  description = "DNS record name"
  type        = string
}

variable "type" {
  description = "DNS record type (A, CNAME, etc.)"
  type        = string
  default     = "CNAME"
}

variable "ttl" {
  description = "TTL in seconds"
  type        = number
  default     = 300
}

variable "records" {
  description = "DNS record values"
  type        = list(string)
}
