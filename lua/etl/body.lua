local ngx_var = ngx.var
local ngx_req = ngx.req
local table_insert = table.insert
local str_gsub = string.gsub

local query_dic = ngx_req.get_uri_args()
ngx_req.read_body()
local request_dic = ngx_req.get_post_args()

local platform =  query_dic['platform'] or nil
platform = platform or (request_dic['platform'] or nil)
platform = platform or ''

if 'android' ~= platform then
    local event_time = request_dic['event_time'] or ''
    event_time = str_gsub(event_time, "(%s+)", '+')
    request_dic['event_time'] = event_time
end

for k, v in pairs(query_dic) do
    if not request_dic[k] then
        local query_key = 'get_k_' .. k
        ngx.var.query_key= v
    end
end

for k, v in pairs(request_dic) do
    if not request_dic[k] then
        local query_key = 'post_k_' .. k
        ngx.var.query_key= v
    end
end
