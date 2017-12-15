local ipdatx = require "resty.ipdatx"
local ok, err = ipdatx.init(ipdatx_path)
local ipip, err = ipdatx:query(ngx.var.remote_addr)
local ip2location = ngx.shared.ip2location