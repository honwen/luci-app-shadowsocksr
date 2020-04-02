-- Copyright (C) 2016 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

module("luci.controller.shadowsocksr", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/shadowsocksr") then
		return
	end

	entry({"admin", "services", "shadowsocksr"},
		alias("admin", "services", "shadowsocksr", "general"),
		_("ShadowSocksR"), 11).dependent = true

	entry({"admin", "services", "shadowsocksr", "general"},
		cbi("shadowsocksr/general"),
		_("General Settings"), 10).leaf = true

	entry({"admin", "services", "shadowsocksr", "status"},
		call("action_status")).leaf = true

	entry({"admin", "services", "shadowsocksr", "servers"},
		arcombine(cbi("shadowsocksr/servers"), cbi("shadowsocksr/servers-details")),
		_("Servers Manage"), 20).leaf = true

	if luci.sys.call("command -v ssr-redir >/dev/null") ~= 0 then
		return
	end

	entry({"admin", "services", "shadowsocksr", "access-control"},
		cbi("shadowsocksr/access-control"),
		_("Access Control"), 30).leaf = true

	entry({"admin", "services", "shadowsocksr", "log"},
		call("action_log"),
		_("System Log"), 90).leaf = true

	if luci.sys.call("command -v /etc/init.d/dnsmasq-extra >/dev/null") ~= 0 then
		return
	end

	entry({"admin", "services", "shadowsocksr", "gfwlist"},
		call("action_gfw"),
		_("GFW-List"), 60).leaf = true

	entry({"admin", "services", "shadowsocksr", "custom"},
		cbi("shadowsocksr/gfwlist-custom"),
		_("Custom-List"), 50).leaf = true

end

local function is_running(name)
	return luci.sys.call("pgrep -x %s >/dev/null" %{name}) == 0
end

function action_status()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		ssr_redir = is_running("ssr-redir"),
		ssr_local = is_running("ssr-local"),
		ssr_tunnel = is_running("ssr-tunnel")
	})
end

function action_log()
	local fs = require "nixio.fs"
	local conffile = "/var/log/shadowsocksr_watchdog.log"
	local watchdog = fs.readfile(conffile) or ""
	luci.template.render("shadowsocksr/plain", {content=watchdog})
end

function action_gfw()
	local fs = require "nixio.fs"
	local conffile = "/etc/dnsmasq-extra.d/gfwlist"
	local gfwlist = fs.readfile(conffile) or ""
	luci.template.render("shadowsocksr/plain", {content=gfwlist})
end
