-----------------------------------------------------------------------------------------------------------------------
--                                                    Blue config                                                    --
-----------------------------------------------------------------------------------------------------------------------

-- Load modules
-----------------------------------------------------------------------------------------------------------------------

-- Standard awesome library
------------------------------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

require("awful.autofocus")

-- User modules
------------------------------------------------------------
local redflat = require("redflat")

-- debug locker
local lock = lock or {}

redflat.startup.locked = lock.autostart
redflat.startup:activate()


-- Error handling
-----------------------------------------------------------------------------------------------------------------------
require("colorless.ercheck-config") -- load file with error handling


-- Setup theme and environment vars
-----------------------------------------------------------------------------------------------------------------------
local env = require("color.blue.env-config") -- load file with environment
env:init({ theme = "blue" })


-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = require("color.blue.layout-config") -- load file with tile layouts setup
layouts:init()


-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mymenu = require("color.blue.menu-config") -- load file with menu configuration
mymenu:init({ env = env })


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- Separator
--------------------------------------------------------------------------------
local separator = redflat.gauge.separator.vertical()

-- Tasklist
--------------------------------------------------------------------------------
local tasklist = {}

-- load list of app name aliases from files and set it as part of tasklist theme
tasklist.style = { appnames = require("color.blue.alias-config")}

tasklist.buttons = awful.util.table.join(
	awful.button({}, 1, redflat.widget.tasklist.action.select),
	awful.button({}, 2, redflat.widget.tasklist.action.close),
	awful.button({}, 3, redflat.widget.tasklist.action.menu),
	awful.button({}, 4, redflat.widget.tasklist.action.switch_next),
	awful.button({}, 5, redflat.widget.tasklist.action.switch_prev)
)

-- Taglist widget
--------------------------------------------------------------------------------
local taglist = {}
taglist.style = { separator = separator, widget = redflat.gauge.tag.blue_icon.new, show_tip = true, tag = {width = 50} }
taglist.buttons = awful.util.table.join(
	awful.button({         }, 1, function(t) t:view_only() end),
	awful.button({ env.mod }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({         }, 2, awful.tag.viewtoggle),
	awful.button({         }, 3, function(t) redflat.widget.layoutbox:toggle_menu(t) end),
	awful.button({ env.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({         }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({         }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Textclock widget
--------------------------------------------------------------------------------
local textclock = {}
textclock.widget = redflat.widget.textclock({ timeformat = "%a %b-%d, %I:%M:%S", dateformat = "%b-%d-%a", timeout = 1 })


-- Layoutbox configure
--------------------------------------------------------------------------------
local layoutbox = {}

layoutbox.buttons = awful.util.table.join(
	awful.button({ }, 1, function () redflat.widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end),
	awful.button({ }, 2, function () mymenu.mainmenu:toggle() end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)
)

-- Tray widget
--------------------------------------------------------------------------------
local tray = {}
tray.widget = redflat.widget.minitray()

tray.buttons = awful.util.table.join(
	awful.button({}, 1, function() redflat.widget.minitray:toggle() end)
)

-- PA volume control
--------------------------------------------------------------------------------
local volume = {}
volume.widget = redflat.widget.pulse(nil, { widget = redflat.gauge.audio.blue.new })

-- activate player widget
redflat.float.player:init({ name = env.player })

volume.buttons = awful.util.table.join(
	awful.button({}, 1, function() volume.widget:mute()                         end),
	awful.button({}, 3, function() awful.spawn("pavucontrol -t 5")        end),
	awful.button({}, 4, function() volume.widget:change_volume()                end),
	awful.button({}, 5, function() volume.widget:change_volume({ down = true }) end)
)

-- System resource monitoring widgets
--------------------------------------------------------------------------------
local sysmon = { widget = {}, buttons = {}, icon = {} }

-- ./icons
sysmon.icon.battery = redflat.util.table.check(beautiful, "wicon.battery")
sysmon.icon.cpuram = redflat.util.table.check(beautiful, "wicon.monitor")

-- battery
sysmon.widget.battery = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.bat(25), arg = "BAT0" },
	{ timeout = 60, widget = redflat.gauge.icon.single, monitor = { is_vertical = true, icon = sysmon.icon.battery } }
)

-- CPU and RAM usage
local cpu_storage = { cpu_total = {}, cpu_active = {} }

local cpuram_func = function()
	local cpu_usage = redflat.system.cpu_usage(cpu_storage).total
	local mem_usage = redflat.system.memory_info().usep

	return {
		text = "CPU: " .. cpu_usage .. "%  " .. "RAM: " .. mem_usage .. "%",
		value = { cpu_usage / 100,  mem_usage / 100},
		alert = cpu_usage > 80 or mem_usage > 70
	}
end

sysmon.widget.cpuram = redflat.widget.sysmon(
	{ func = cpuram_func },
	{ timeout = 2,  widget = redflat.gauge.monitor.double, monitor = { icon = sysmon.icon.cpuram } }
)

sysmon.buttons.cpuram = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("cpu") end)
)


-- Screen setup
-----------------------------------------------------------------------------------------------------------------------

-- aliases for setup
local al = awful.layout.layouts

-- setup
awful.screen.connect_for_each_screen(
	function(s)
		-- wallpaper
		env.wallpaper(s)
		for out,_ in pairs(s.outputs) do
			if out == "DP1" then
				awful.tag.add("Main", {
					icon = "wicon.main",
					layout = al[1],
					screen = s,
					selected = true,
				})

				awful.tag.add("Message", {
					icon = "wicon.message",
					layout = al[1],
					screen = s,
				})

				awful.tag.add("Web", {
					icon = "wicon.web",
					layout = al[1],
					screen = s,
				})

				awful.tag.add("Doc", {
					icon = "wicon.doc",
					layout = al[1],
					screen = s,
				})

				awful.tag.add("Media", {
					icon = "wicon.media",
					layout = al[1],
					screen = s,
				})
			elseif out == "DP3" then
				awful.tag.add("Main", {
					icon = "wicon.main",
					layout = al[1],
					screen = s,
					selected = true,
				})

				awful.tag.add("Web", {
					icon = "wicon.web",
					layout = al[1],
					screen = s,
				})

				awful.tag.add("Dev", {
					icon = "wicon.dev",
					layout = al[1],
					screen = s,
				})

				awful.tag.add("Doc", {
					icon = "wicon.doc",
					layout = al[1],
					screen = s,
				})

				awful.tag.add("Media", {
					icon = "wicon.media",
					layout = al[1],
					screen = s,
				})
			else 
				awful.tag.add("Main", {
					icon = "wicon.main",
					layout = al[1],
					screen = s,
					selected = true,
				})

				awful.tag.add("Web", {
					icon = "wicon.web",
					layout = al[1],
					screen = s,
				})

				awful.tag.add("Doc", {
					icon = "wicon.doc",
					layout = al[1],
					screen = s,
				})

				awful.tag.add("Media", {
					icon = "wicon.media",
					layout = al[1],
					screen = s,
				})
			end
		end

		-- layoutbox widget
		layoutbox[s] = redflat.widget.layoutbox({ screen = s })

		-- taglist widget
		taglist[s] = redflat.widget.taglist({ screen = s, buttons = taglist.buttons, hint = env.tagtip }, taglist.style)

		-- tasklist widget
		tasklist[s] = redflat.widget.tasklist({ screen = s, buttons = tasklist.buttons }, tasklist.style)

		-- panel wibox
		s.panel = awful.wibar({ position = "top", screen = s, height = 32 })

		-- add widgets to the wibox
		if s.index == 1 then
			s.panel:setup {
				layout = wibox.layout.align.horizontal,
				{ -- left widgets
					layout = wibox.layout.fixed.horizontal,

					env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
					separator,
					env.wrapper(taglist[s], "taglist"),
					separator,
				},
				{ -- middle widget
					layout = wibox.layout.fixed.horizontal,
					expand = "outside",

					nil,
					env.wrapper(tasklist[s], "tasklist"),
				},
				{ -- right widgets
					layout = wibox.layout.fixed.horizontal,

					separator,
					env.wrapper(sysmon.widget.cpuram, "cpuram", sysmon.buttons.cpuram),
					separator,
					env.wrapper(volume.widget, "volume", volume.buttons),
					env.wrapper(sysmon.widget.battery, "battery"),
					separator,
					env.wrapper(textclock.widget, "textclock"),
					separator,
					env.wrapper(tray.widget, "tray", tray.buttons),
					-- separator,
				},
			}
		else
			s.panel:setup {
				layout = wibox.layout.align.horizontal,
				{ -- left widgets
					layout = wibox.layout.fixed.horizontal,
	
					env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
					separator,
					env.wrapper(taglist[s], "taglist"),
					separator,
				},
				{ -- middle widget
					layout = wibox.layout.fixed.horizontal,
					expand = "outside",
	
					nil,
					env.wrapper(tasklist[s], "tasklist"),
				},
			}
		end
	end
)


-- Desktop widgets
-----------------------------------------------------------------------------------------------------------------------
-- if not lock.desktop then
--  	local desktop = require("color.blue.desktop-config") -- load file with desktop widgets configuration
-- 	desktop:init({
-- 		env = env,
-- 		buttons = awful.util.table.join(
-- 			awful.button({}, 3, function () mymenu.mainmenu:toggle() end)
-- 		)
-- 	})
-- end


-- Active screen edges
-----------------------------------------------------------------------------------------------------------------------
local edges = require("color.blue.edges-config") -- load file with edges configuration
edges:init()


-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local appkeys = require("color.blue.appkeys-config") -- load file with application keys sheet

local hotkeys = require("color.blue.keys-config") -- load file with hotkeys configuration
hotkeys:init({ env = env, menu = mymenu.mainmenu, appkeys = appkeys, volume = volume.widget })


-- Rules
-----------------------------------------------------------------------------------------------------------------------
local rules = require("color.blue.rules-config") -- load file with rules configuration
rules:init({ hotkeys = hotkeys})


-- Titlebar setup
-----------------------------------------------------------------------------------------------------------------------
local titlebar = require("colorless.titlebar-config") -- load file with titlebar configuration
titlebar:init()


-- Base signal set for awesome wm
-----------------------------------------------------------------------------------------------------------------------
local signals = require("colorless.signals-config") -- load file with signals configuration
signals:init({ env = env })


-- Autostart user applications
-----------------------------------------------------------------------------------------------------------------------
if redflat.startup.is_startup then
	local autostart = require("color.blue.autostart-config") -- load file with autostart application list
	autostart.run()
end
