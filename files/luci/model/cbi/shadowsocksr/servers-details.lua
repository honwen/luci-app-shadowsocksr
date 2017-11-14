-- Copyright (C) 2016 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local shadowsocksr = "shadowsocksr"
local sid = arg[1]
local encrypt_methods = {
	"none",
	"table",
	"rc4",
	"rc4-md5",
	"aes-128-cfb",
	"aes-192-cfb",
	"aes-256-cfb",
	"aes-128-ctr",
	"aes-192-ctr",
	"aes-256-ctr",
	"bf-cfb",
	"camellia-128-cfb",
	"camellia-192-cfb",
	"camellia-256-cfb",
	"salsa20",
	"chacha20",
	"chacha20-ietf",
}

local plugin_protocols = {
	"origin",
	"auth_sha1",
	"auth_sha1_v2",
	"auth_sha1_v4",
	"auth_aes128_md5",
	"auth_aes128_sha1",
	"auth_chain_a",
	"auth_chain_b",
	"auth_chain_c",
	"auth_chain_d",
	"auth_chain_e",
	"auth_chain_f",
}

local plugin_obfss = {
	"plain",
	"http_simple",
	"http_post",
	"tls1.2_ticket_auth",
}

local function has_bin(name)
	return luci.sys.call("command -v %s >/dev/null" %{name}) == 0
end

local function support_fast_open()
	return luci.sys.exec("cat /proc/sys/net/ipv4/tcp_fastopen 2>/dev/null"):trim() == "3"
end

m = Map(shadowsocksr, "%s - %s" %{translate("ShadowSocksR"), translate("Edit Server")})
m.redirect = luci.dispatcher.build_url("admin/services/shadowsocksr/servers")

if m.uci:get(shadowsocksr, sid) ~= "servers" then
	luci.http.redirect(m.redirect)
	return
end

-- [[ Edit Server ]]--
s = m:section(NamedSection, sid, "servers")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Alias(optional)"))
o.rmempty = true

if support_fast_open() and has_bin("ss-local") then
	o = s:option(Flag, "fast_open", translate("TCP Fast Open"))
	o.rmempty = false
end

o = s:option(Value, "server", translate("Server Address"))
o.datatype = "host"
o.rmempty = false

o = s:option(Value, "server_port", translate("Server Port"))
o.datatype = "port"
o.rmempty = false

o = s:option(Value, "timeout", translate("Connection Timeout"))
o.datatype = "uinteger"
o.default = 60
o.rmempty = false

o = s:option(Value, "password", translate("Password"))
o.password = true
o.rmempty = false

o = s:option(ListValue, "encrypt_method", translate("Encrypt Method"))
for _, v in ipairs(encrypt_methods) do o:value(v, v:upper()) end
o.rmempty = false

o = s:option(ListValue, "plugin_protocol", translate("PROTOCOL"))
for _, v in ipairs(plugin_protocols) do o:value(v, v:upper()) end
o.rmempty = false

o = s:option(Value, "plugin_protocol_param", translate("PROTOCOL-PARAM"))
o.rmempty = true

o = s:option(ListValue, "plugin_obfs", translate("OBFS"))
for _, v in ipairs(plugin_obfss) do o:value(v, v:upper()) end
o.rmempty = false

o = s:option(Value, "plugin_obfs_param", translate("OBFS-PARAM"))
o.datatype = "host"
o.default = "bing.com"
o.rmempty = true

return m
