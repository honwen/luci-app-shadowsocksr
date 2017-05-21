-- Copyright (C) 2016 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

module("luci.controller.shadowsocks", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/shadowsocks") then
		return
	end

	entry({"admin", "services", "shadowsocks"},
		alias("admin", "services", "shadowsocks", "general"),
		_("ShadowSocks"), 10).dependent = true

	entry({"admin", "services", "shadowsocks", "general"},
		cbi("shadowsocks/general"),
		_("General Settings"), 10).leaf = true

	entry({"admin", "services", "shadowsocks", "servers"},
		arcombine(cbi("shadowsocks/servers"), cbi("shadowsocks/servers-details")),
		_("Servers Manage"), 20).leaf = true

	if luci.sys.call("command -v ssr-redir >/dev/null") ~= 0 then
		return
	end

	entry({"admin", "services", "shadowsocks", "access-control"},
		cbi("shadowsocks/access-control"),
		_("Access Control"), 30).leaf = true

	entry({"admin", "services", "shadowsocks", "log"},
		call("action_log"),
		_("System Log"), 90).leaf = true

	if luci.sys.call("command -v /etc/init.d/dnsmasq-extra >/dev/null") ~= 0 then
		return
	end

	entry({"admin", "services", "shadowsocks", "gfwlist"},
		call("action_gfw"),
		_("GFW-List"), 60).leaf = true

	entry({"admin", "services", "shadowsocks", "custom"},
		cbi("shadowsocks/gfwlist-custom"),
		_("Custom-List"), 50).leaf = true

end

function action_log()
	local fs = require "nixio.fs"
	local conffile = "/var/log/shadowsocks_watchdog.log"
	local watchdog = fs.readfile(conffile) or ""
	luci.template.render("admin_status/syslog", {syslog=watchdog})
end

function action_gfw()
	local fs = require "nixio.fs"
	local conffile = "/etc/dnsmasq-extra.d/gfwlist"
	local gfwlist = fs.readfile(conffile) or ""
	luci.template.render("shadowsocks/gfwlist", {gfwlist=gfwlist})
end
