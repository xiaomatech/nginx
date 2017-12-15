local ck = require "resty.cookie"
local cookie, err = ck:new()
local fields, err = cookie:get_all()