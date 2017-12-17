local ipdatx = require "resty.ipdatx"
local ok, err = ipdatx.init(ipdatx_path)
local ipip, err = ipdatx:query(ngx.var.remote_addr)
local ip2location = ngx.shared.ip2location

-- local geo = require 'resty.maxminddb'
-- local maxm = geo.new("/path/to/GeoLite2-City.mmdb")
-- local res,err = maxm:lookup(ngx.var.arg_ip or ngx.svar.remote_addr)