provider "aws" {
  region = "me-south-1"
}

module "testalb" {
  source            = "../../modules/alb"
  access_log_bucket = "test-bucket-alb2xd"
  aws_region        = "ap-southeast-1"

  waf_additional_rules = [
    {
      "WAFCustompathRule" = "${aws_wafregional_rule.custom_path_rule.id}"
      "priority"          = 15
      "action"            = "BLOCK"
    },
  ]

  waf_whitelist_ipset = [
    {
      value = "1.1.1.1/32"

      type = "IPV4"
    },
    {
      value = "2.2.2.2/32"

      type = "IPV4"
    },
  ]

  waf_blacklist_ipset = [
    {
      value = "3.3.3.3/32"

      type = "IPV4"
    },
  ]
}

resource "aws_wafregional_regex_pattern_set" "custom_path" {
  name                  = "forbid-jobs-path"
  regex_pattern_strings = ["/jobs"]
}

resource "aws_wafregional_regex_match_set" "custom_path" {
  name = "custom-url-path"

  regex_match_tuple {
    field_to_match {
      type = "URI"
    }

    regex_pattern_set_id = "${aws_wafregional_regex_pattern_set.custom_path.id}"
    text_transformation  = "NONE"
  }
}

resource "aws_wafregional_rule" "custom_path_rule" {
  name        = "${var.stack_name} Custom Path Rule"
  metric_name = "${var.stack_name}CustomPathRule"

  predicate {
    type    = "RegexMatch"
    data_id = "${aws_wafregional_regex_match_set.custom_path.id}"
    negated = false
  }
}

variable "stack_name" {
  default = "ALBStack"
}
