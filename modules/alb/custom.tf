module "configure_access_log_bucket" {
  source              = "github.com/avirahul007/terraform-aws-lambda-exec.git?ref=1.0.6"
  name                = "${var.stack_name}ConfigureAccessLogBucket"
  lambda_function_arn = "${aws_lambda_function.custom_resource.arn}"
  custom_name         = "ConfigureAccessLogBucket"

  lambda_inputs = {
    Region                     = "${var.aws_region}"
    AccessLogBucket            = "${var.access_log_bucket}"
    LambdaWAFLogParserFunction = "${aws_lambda_function.log_parser.arn}"
  }

  lambda_outputs = []
}

module "populate_reputation_list" {
  source              = "github.com/avirahul007/terraform-aws-lambda-exec.git?ref=1.0.6"
  name                = "${var.stack_name}PopulateReputationList"
  lambda_function_arn = "${aws_lambda_function.custom_resource.arn}"
  custom_name         = "PopulateReputationList"

  lambda_inputs = {
    count                                  = "${var.scanner_probe_protection_activated == "yes" ? 1 : 0}"
    Region                                 = "${var.aws_region}"
    LambdaWAFReputationListsParserFunction = "${aws_lambda_function.reputation_lists_parser.arn}"
    WAFReputationListsSet                  = "${aws_wafregional_ipset.waf_reputation_set.id}"
  }

  lambda_outputs = []
}

module "configure_web_acl" {
  source              = "github.com/avirahul007/terraform-aws-lambda-exec.git?ref=1.0.6"
  name                = "${var.stack_name}ConfigureWebAcl"
  lambda_function_arn = "${aws_lambda_function.custom_resource.arn}"
  custom_name         = "ConfigureWebAcl"

  lambda_inputs = {
    SqlInjectionProtectionActivated       = "${var.sql_injection_protection_activated}"
    CrossSiteScriptingProtectionActivated = "${var.cross_site_scripting_protection_activated}"
    HttpFloodProtectionActivated          = "${var.http_flood_protection_activated}"
    ScannersProbesProtectionActivated     = "${var.scanner_probe_protection_activated}"
    ReputationListsProtectionActivated    = "${var.reputation_lists_protection_activated}"
    BadBotProtectionActivated             = "${var.bad_bot_protection_activated}"

    # AWS WAF Web ACL
    WAFWebACL = "${aws_wafregional_web_acl.WAFWebACL.id}"

    # AWS WAF Rules
    WAFWhitelistRule         = "${aws_wafregional_rule.waf_whitelist.id}"
    WAFBlacklistRule         = "${aws_wafregional_rule.waf_blacklist.id}"
    WAFSqlInjectionRule      = "${var.sql_injection_protection_activated == "yes" ? aws_wafregional_rule.waf_sql_injection.id : ""}"
    WAFXssRule               = "${var.cross_site_scripting_protection_activated == "yes" ? aws_wafregional_rule.waf_xss.id : ""}"
    RateBasedRule            = "${var.http_flood_protection_activated == "yes" ? aws_wafregional_rate_based_rule.waf_rate_based_rule.id : ""}"
    WAFScannersProbesRule    = "${var.scanner_probe_protection_activated == "yes" ? aws_wafregional_rule.waf_scanner_probe.id : ""}"
    WAFIPReputationListsRule = "${var.reputation_lists_protection_activated == "yes" ? aws_wafregional_rule.waf_reputation.id : ""}"
    WAFBadBotRule            = "${var.bad_bot_protection_activated == "yes" ? aws_wafregional_rule.waf_bad_bot.id : ""}"

    # AWS WAF IP Sets
    WAFWhitelistSet       = "${aws_wafregional_ipset.waf_whitelist_set.id}"
    WAFBlacklistSet       = "${aws_wafregional_ipset.waf_blacklist_set.id}"
    WAFScannersProbesSet  = "${var.scanner_probe_protection_activated == "yes" ? aws_wafregional_ipset.waf_scanner_probe_set.id : ""}"
    WAFReputationListsSet = "${var.reputation_lists_protection_activated == "yes" ? aws_wafregional_ipset.waf_reputation_set.id : ""}"
    WAFBadBotSet          = "${var.bad_bot_protection_activated == "yes" ? aws_wafregional_ipset.waf_bad_bot_set.id : ""}"

    # Additional RUles
    WAFAdditionalRules = "${var.waf_additional_rules}"

    # Extra Info
    UUID                   = "${random_uuid.uuid.result}"
    Region                 = "${var.aws_region}"
    RequestThreshold       = "${var.request_threshold}"
    ErrorThreshold         = "${var.error_threshold}"
    WAFBlockPeriod         = "${var.waf_block_period}"
    SendAnonymousUsageData = "${var.send_anonymous_usage_data}"
  }

  lambda_outputs = []
}
