local cjson = require "cjson"
local producer = require "resty.kafka.producer"

local broker_list = {
    { host = "127.0.0.1", port = 9092 },
}

local key = "key"
local message = "halo world"

-- this is async producer_type and bp will be reused in the whole nginx worker
local bp = producer:new(broker_list, { producer_type = "async" })

local ok, err = bp:send("test", key, message)
if not ok then
    ngx.say("send err:", err)
    return
end
