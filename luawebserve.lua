#!/usr/bin/lua

-- based on https://github.com/jschornick/openwrt_exporter/blob/master/metrics.lua
socket = require("socket")

-- Allow us to call unpack under both lua5.1 and lua5.2+
local unpack = unpack or table.unpack

hello=[[<style> td, a { text-decoration: none; font-size: 4em; padding: 10px; } table, .btn { display: block; }
    .open { background-color: green; } .stop{ background-color: red; } .close{ background-color: yellow; }
    </style><table>
    <tr><td><a class='btn open' href=/ducks/open>open</a></td>
        <td><a class='btn stop' href=/ducks/stop>stop</a></td></tr>
        <td><a class='btn close' href=/ducks/close>close</a></td></tr>
    <tr><td>$D</td><td>$D</td></tr>
    <tr><td>door position is</td><td>$D</td></tr>
    </table>]]

function http_ok_header()
  output("HTTP/1.1 200 OK\r")
  output("Server: luawebserve\r")
  output("Content-Type: text/html; version=0.0.4\r")
  output("\r")
end

function serve(request)
  if not string.match(request, "GET /ducks.*") then
    http_ok_header()
    output(hello)
  else
    http_ok_header()
    output(request)
  end
  client:close()
  return true
end

-- Main program
-- see if a port number is specified as a parameter, if so run the server
for k,v in ipairs(arg) do
  if (v == "-p") or (v == "--port") then
    port = arg[k+1]
  end
end

if port then
  server = assert(socket.bind("*", port))

  while 1 do
    client = server:accept()
    client:settimeout(60)
    local request, err = client:receive()

    if not err then
      output = function (str) client:send(str.."\n") end
      if not serve(request) then
        break
      end
    end
  end
else
  print("you must specify a port number, like -p 8001\r")
end
