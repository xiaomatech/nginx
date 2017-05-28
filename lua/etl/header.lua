local woothee = require "resty.woothee"
local ipdatx = require "resty.ipdatx"
local cjson = require "cjson"
local cjson_safe = require "cjson.safe"
local cjson_encode = cjson_safe.encode
local cjson_decode = cjson_safe.decode
local str_format = string.format
local str_gmatch = string.gmatch
local table_insert = table.insert
local str_gsub = string.gsub
local ngx_var = ngx.var

local r = woothee.parse(ngx_var.http_user_agent)
ngx_var.x_ua_name       = r.name
ngx_var.x_ua_category   = r.category
ngx_var.x_ua_os         = r.os
ngx_var.x_ua_version    = r.version
ngx_var.x_ua_vendor     = r.vendor
ngx_var.x_ua_os_version = r.os_version


function string:split(delimiter)
    local result = {}
    local _delimiter = str_format("([^'%s']+)", delimiter)
    for w in str_gmatch(self, _delimiter) do
        table_insert(result, w)
    end
    return result
end

function parse_referer(referer)

end

function parse_cookie(cookie)
    local cookies = string.split(cookie, ';')
end


local ok, err = ipdatx.init(ipdatx_path)
local ipip, err = ipdatx:query(ngx_var.remote_addr)
ngx.var.ipip_country        = ipip.data[1]
ngx.var.ipip_province       = ipip.data[2]
ngx.var.ipip_city           = ipip.data[3]
ngx.var.ipip_org            = ipip.data[4]
ngx.var.ipip_service        = ipip.data[5]
ngx.var.ipip_latitude       = ipip.data[6]
ngx.var.ipip_longitude      = ipip.data[7]
ngx.var.ipip_timezone       = ipip.data[8]
ngx.var.ipip_code           = ipip.data[9]
ngx.var.ipip_country_phone  = ipip.data[10]
ngx.var.ipip_contry         = ipip.data[11]
ngx.var.ipip_world_code     = ipip.data[12]


local cookie = parse_cookie(ngx_var.http_cookie)
local referer = parse_referer(ngx_var.http_referer)
