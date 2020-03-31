-----------------------------------------------------------------------------------------------------------------------
--                                               RedFlat clock widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Text clock widget with date in tooltip (optional)
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.widget.textclock v3.5.2
------ (c) 2009 Julien Danjou
-----------------------------------------------------------------------------------------------------------------------

local setmetatable = setmetatable
local os = os
local textbox = require("wibox.widget.textbox")
local beautiful = require("beautiful")
local gears = require("gears")

local tooltip = require("redflat.float.tooltip")
local redutil = require("redflat.util")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local textclock = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		font  = "Sans 12",
		tooltip = {},
		color = { text = "#aaaaaa" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.textclock") or {})
end

local function quotient(i, j)
	return math.floor(i/j)
end

local function mod(i, j)
	return math.floor(( i - ( j * quotient( i, j ) ) ))
end

local function gregorianToJDN(year, month, day)
	s   = quotient ( year    ,   4 )
			- quotient ( year - 1,   4 )
			- quotient ( year    , 100 )
			+ quotient ( year - 1, 100 )
			+ quotient ( year    , 400 )
			- quotient ( year - 1, 400 )

	t   = quotient ( 14 - month, 12 )

	n   = 31 * t * ( month - 1 )
			+ ( 1 - t ) * ( 59 + s + 30 * (month - 3) + quotient( (3*month - 7), 5) )
			+ day - 1

	j   = 	1721426
			+ 365 * (year - 1)
			+ quotient ( year - 1,   4 )
			- quotient ( year - 1, 100 )
			+ quotient ( year - 1, 400 )
			+ n

	return j;
end

local function ethiopian_date()

	year = os.date("%Y")
	month = os.date("%m")
	day = os.date("%d")

	era = 1723856
	jdn = gregorianToJDN(year, month, day)

	r = mod( (jdn - era), 1461 )
	n = mod( r, 365 ) + 365 * quotient( r, 1460 )
	
	et_year = 4 * quotient( (jdn - era), 1461 )
		+ quotient( r, 365 )
		- quotient( r, 1460 )
	et_month = quotient( n, 30 ) + 1
	et_day   = mod( n, 30 ) + 1 

	return et_day .. " / " .. et_month .. " / " .. et_year .. " Et."
end

-- Create a textclock widget. It draws the time it is in a textbox.
-- @param format The time format. Default is " %a %b %d, %H:%M ".
-- @param timeout How often update the time. Default is 60.
-- @return A textbox widget
-----------------------------------------------------------------------------------------------------------------------
function textclock.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	args = args or {}
	local timeformat = args.timeformat or " %a %b %d, %H:%M "
	local timeout = args.timeout or 60
	style = redutil.table.merge(default_style(), style or {})

	-- Create widget
	--------------------------------------------------------------------------------
	local widg = textbox()
	widg:set_font(style.font)

	-- Set tooltip if need
	--------------------------------------------------------------------------------
	local tp
	if args.dateformat then tp = tooltip({ objects = { widg } }, style.tooltip) end

	-- Set update timer
	--------------------------------------------------------------------------------
	local timer = gears.timer({ timeout = timeout })
	timer:connect_signal("timeout",
		function()
			widg:set_markup('<span color="' .. style.color.text .. '">' .. os.date(timeformat) .. "</span>")
			if args.dateformat then tp:set_text(ethiopian_date()) end
		end)
	timer:start()
	timer:emit_signal("timeout")

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call textclock module as function
-----------------------------------------------------------------------------------------------------------------------
function textclock.mt:__call(...)
	return textclock.new(...)
end

return setmetatable(textclock, textclock.mt)
