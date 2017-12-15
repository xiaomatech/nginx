local cjson_safe = require "cjson.safe"
local cjson_encode = cjson_safe.encode
local ngx_decode_args = ngx.decode_args

ngx.var.x_arg = cjson_encode(ngx_decode_args(ngx.var.args))