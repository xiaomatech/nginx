local ipdatx = require "resty.ipdatx"
local cjson_safe = require "cjson.safe"
local cjson_encode = cjson_safe.encode

local ok, err = ipdatx.init(ipdatx_path)
local ipip, err = ipdatx:query(ngx.var.remote_addr)

ngx.var.ipip = cjson_encode(ipip)