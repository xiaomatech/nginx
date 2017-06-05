local http = require "resty.http"
local json = require "cjson"

local ngx_timer_at = ngx.timer.at
local ngx_log = ngx.log
local ngx_ERR = ngx.ERR
local ngx_INFO = ngx.INFO
local ngx_worker_exiting = ngx.worker.exiting
local ngx_match = ngx.re.match
local ngx_localtime = ngx.localtime
local ngx_sleep = ngx.sleep

local _M = {}
local mt = { __index = _M }

local function log_error(...)
    ngx_log(ngx_ERR, ...)
end

local function log_info(...)
    ngx_log(ngx_INFO, ...)
end

local function get_allkeys(self,key)
    local conf = self.conf
    local c = http:new()
    c:set_timeout(5000)
    local ok, err = c:connect(conf.etcd_host,conf.etcd_port)
    if not ok then
        log_error(err)
        ngx_sleep(5)
    end
    local url
    if not key then
        url = "/v2/keys" .. conf.etcd_path
    else
        url = "/v2/keys" .. key
    end
    local res, err = c:request({path = url, method = "GET"})
    if not err then
        local body, err = res:read_body()
        if not err then
            local all = json.decode(body)
            if not all.errorCode and all.node.nodes then
                for k,v in pairs(all.node.nodes) do
                    if v.dir then
                        get_allkeys(self,v.key)
                    else
                        self[v.key] = json.decode(v.value)
                    end
                end
            end
        else
            return nil, err
        end
        self.version = res.headers["x-etcd-index"]
    else
        return nil, err
    end
    c:set_keepalive(5000,10)
    return 1
end

local function delete_dir(self,key)
    for k,v in pairs(self)
    do
        local m, err = ngx_match(k,key,"j")
        if m then
            self[k] = nil
        elseif err then
            log_error(err)
        end
    end
end

local function watch(premature, self, index)
    if premature then
        return
    end

    if ngx_worker_exiting() then
        return
    end

    local conf = self.conf

    local c = http:new()

    local nextIndex
    local url = "/v2/keys" .. conf.etcd_path

    if index == nil then
        get_allkeys(self)
        if self.version then
            nextIndex = self.version + 1
        end
    else
        c:set_timeout(120000)
        local ok, err = c:connect(conf.etcd_host, conf.etcd_port)
        if not ok then
            log_error(err)
            ngx_sleep(5)
        end
        local s_url = url .. "?wait=true&recursive=true&waitIndex=" .. index
        local res, err = c:request({ path = s_url, method = "GET" })
        if not err then
            local body, err = res:read_body()
            if not err then
                local change = json.decode(body)
                if not change.errorCode then
                    local action = change.action
                    if change.node.dir then
                        if action == "delete" then
                            delete_dir(self,change.node.key)
                            log_info("DELETE DIR [".. change.node.key .. "]")
                        end
                    else
                        local ok, value = pcall(json.decode, change.node.value)
                        if action == "delete" or action == "expire" then
                            if self[change.node.key] then
                                self[change.node.key] = nil
                            end
                        elseif action == "set" or action == "update" then
                            self[change.node.key] = value
                        end
                    end
                    self.version = change.node.modifiedIndex
                    nextIndex = self.version + 1
                elseif change.errorCode == 401 then
                    nextIndex = nil
                end
            elseif err == "timeout" then
                nextIndex = res.headers["x-etcd-index"] + 1
            end
        end
    end

    local ok, err = ngx_timer_at(0, watch, self, nextIndex)
    if not ok then
        log_error("Error start watch: ", err)
    end
    return
end

function _M.new(self,conf)
    return setmetatable({conf = conf},mt)
end

function _M.init(self)
    local ok, err = ngx_timer_at(0, watch, self, nextIndex)
    if not ok then
        log_error("Error start watch: " .. err)
        return nil, err
    end
    return 1
end

local function copyTable(t1,t2)
    for k,v in pairs(t1)
    do
        if not t2[k] then
            t2[k] = v
        else
            if type(v) == "table" then
                copyTable(v,t2[k])
            end
        end
    end
end

function _M.set_config(self,action,key,value)
    local conf = self.conf
    if not action then
        log_error("require action")
        return nil, "require action"
    end
    if not key then
        log_error("require key")
        return nil, "require key"
    end
    local value = value or {}
    local valid_action = {["PUT"] = 1, ["DELETE"] = 1}
    if not valid_action[action] then
        log_error("action only can be PUT or DELETE")
        return nil, "action only can be PUT or DELETE"
    end
    local method = "PUT"
    if action == "DELETE" then
        method = "DELETE"
    end
    if key == conf.etcd_path then
        log_error("key invalid")
        return nil, "key invalid"
    end
    local m, err = ngx_match(key,"^" .. conf.etcd_path,"j")
    if not m then
        if err then
            log_error(err)
        end
        return nil, "key wrong"
    end
    local src_value = self[key]
    if method == "PUT" and type(src_value) == "table" then
        copyTable(src_value,value)
    end
    value.time = ngx_localtime()
    local etcd_host = conf["etcd_host"]
    local etcd_port = conf["etcd_port"]
    local url = "/v2/keys" .. key .. "?recursive=true"
    local c = http:new()
    c:set_timeout(5000)
    c:connect(etcd_host,etcd_port)
    local res, err = c:request({path=url,method = method,body = "value=" .. json.encode(value),headers = {["Content-Type"] = "application/x-www-form-urlencoded"}})
    if not err then
        local body, err = res:read_body()
        if not err then
            local all = json.decode(body)
            if all.errorCode then
                log_error(body)
                return nil, body
            else
                return true
            end
        else
            log_error(err)
            return nil, err
        end
    else
        log_error(err)
        return nil, err
    end
end

function _M.status(self)
    return json.encode(self)
end

return _M