local cjson = require "cjson"
local producer = require "resty.kafka.producer"

local access_log = {}
access_log["uri"]=ngx.var.uri
access_log["args"]=ngx.var.args
access_log["host"]=ngx.var.host
access_log["request_body"]=ngx.var.request_body
access_log["remote_addr"] = ngx.var.remote_addr
access_log["remote_user"] = ngx.var.remote_user
access_log["time_local"] = ngx.var.time_local
access_log["status"] = ngx.var.status
access_log["body_bytes_sent"] = ngx.var.body_bytes_sent
access_log["http_referer"] = ngx.var.http_referer
access_log["http_user_agent"] = ngx.var.http_user_agent
access_log["http_x_forwarded_for"] = ngx.var.http_x_forwarded_for
access_log["upstream_response_time"] = ngx.var.upstream_response_time
access_log["request_time"] = ngx.var.request_time


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
