variable "domain_name" {
  description = "The domain name for the website (leave empty if you will use CloudFront for example)"
  type        = string
  default     = ""
}

variable "zone_domain_name" {
  description = "The domain name for the zone to search for (can be the same as domain_name or empty)"
  type        = string
  default     = ""
}
