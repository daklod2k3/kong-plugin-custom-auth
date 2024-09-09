local http = require "resty.http"
local ngx = require "ngx"
local cjson = require "cjson"

local ExternalAuthHandler = {
  VERSION = "1.0",
  PRIORITY = 1000,
}

function ExternalAuthHandler:access(conf)
  local path = kong.request.get_path()
  local publicPaths = conf.public_paths;
  local token = nil


  -- local cookieToken = nil
  local headerToken = kong.request.get_header("Authorization")


  local cookie = require "resty.cookie"

  local ck = cookie:new()
  local cookieToken, err = ck:get("token")

  -- if cookieToken == nil then
  --   kong.log("No token found in cookie")
  -- end

  if not cookieToken then
     token = headerToken
  else 
    token =  "Bearer " .. cookieToken
  end

  -- kong.log("Token: ", headerToken, cookieToken)

  if token == nil then
    kong.log.err("No token found")
    return kong.response.exit(401)
  end

  for i, pub_path in ipairs(publicPaths) do
    if pub_path == path then
      return
    end
  end

  local client = http.new()

  kong.log("Validating Authentication: ", conf.url)
  local res, err = client:request_uri(conf.url, {
    ssl_verify = false,
    headers = {
      Authorization = token,
    }
  })

  if not res then
    kong.log.err("Invalid Authentication Response: ", err)
    return kong.response.exit(500)
  end

  if res.status ~= 200 then
    kong.log.err("Invalid Authentication Response Status: ", res.status)
    return kong.response.exit(401)
  end

  local json = cjson.encode(res.body)
  local user_info = cjson.decode(json)
  kong.service.request.set_header("X-UserInfo", ngx.encode_base64(user_info))
end

return ExternalAuthHandler