local useragent = ngx.shared.useragent

local woothee = require "resty.woothee"
local r = woothee.parse(ngx.var.http_user_agent)
