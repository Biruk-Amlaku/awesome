-----------------------------------------------------------------------------------------------------------------------
--                                                   RedFlat tag widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Custom widget to display tag info
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local string = string
local type = type
local pcall = pcall
local print = print
local math = math

local base = require("wibox.widget.base")
local wibox = require("wibox")
local beautiful = require("beautiful")
local surface = require("gears.surface")
local color = require("gears.color")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")

local pixbuf
local function load_pixbuf()
	local _ = require("lgi").Gdk
	pixbuf = require("lgi").GdkPixbuf
end
local is_pixbuf_loaded = pcall(load_pixbuf)

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local blueicontag = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width      = 50,
		font       = { font = "Sans", size = 16, face = 0, slant = 0 },
		text_shift = 32,
		point      = { height = 4, gap = 5, dx = 3, width = 25 },
		show_min   = false,
		color      = { main  = "#b1222b", gray = "#575757", icon = "#a0a0a0", urgent = "#32882d" }
	}

	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.tag.blue") or {})
end

-- Check if given argument is SVG file
local function is_svg(args)
	return type(args) == "string" and string.match(args, "%.svg")
end

-- Check if need scale image
local function need_scale(widg, width, height)
	return (widg._image.width ~= width or widg._image.height ~= height) and widg.resize_allowed
end

-- Cache functions
local function get_cache(file, width, height)
	return cache[file .. "-" .. width .. "x" .. height]
end

local function set_cache(file, width, height, surf)
	cache[file .. "-" .. width .. "x" .. height] = surf
end

-- Get cairo pattern
local function get_current_pattern(cr)
	cr:push_group()
	cr:paint()
	return cr:pop_group()
end

-- Create Gdk PixBuf from SVG file with given sizes
local function pixbuf_from_svg(file, width, height)
	local cached = get_cache(file, width, height)

	if cached then
		return cached
	else
		-- naughty.notify({ text = file })
		local buf = pixbuf.Pixbuf.new_from_file_at_scale(file, width, height, true)
		set_cache(file, width, height, buf)
		return buf
	end
end


-- Create a new tag widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function blueicontag.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})

	-- updating values
	local data = {
		state = {
			icon = redutil.base.placeholder(),
		},
		width = style.width or nil
	}

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	-- User functions
	------------------------------------------------------------
	function widg:set_state(state)
		data.state = state
		
		image_name = state.icon

		local loaded_image
		if type(image_name) == "string" then
			local success, result = pcall(surface.load, image_name)
			if not success then
				print("Error while reading '" .. image_name .. "': " .. result)
				return false
			end
			self.image_name = image_name
			loaded_image = result
		else
			loaded_image = surface.load(image_name)
		end

		if loaded_image and (loaded_image.height <= 0 or loaded_image.width <= 0) then return false end

		self._image = loaded_image
		self.is_svg = is_svg(image_name)

		self:emit_signal("widget::redraw_needed")
	end

	function widg:set_width(width)
		data.width = width
		self:emit_signal("widget::redraw_needed")
	end

	-- Fit
	------------------------------------------------------------
	function widg:fit(_, width, height)
		if data.width then
			return math.min(width, data.width), height
		else
			return width, height
		end
	end

	-- Draw
	------------------------------------------------------------
	function widg:draw(_, cr, width)
		local n = #data.state.list
		height = 20


		local w, h = self._image.width, self._image.height
		local aspect = math.min(width / w, height / h)

		cr:save()
		-- let's scale the image so that it fits into (width, height)
		if need_scale(self, width, height) then
			if self.is_svg and self.vector_resize_allowed and is_pixbuf_loaded then
				-- for vector image
				local pixbuf_ = pixbuf_from_svg(self.image_name, math.floor(w * aspect), math.floor(h * aspect))
				cr:set_source_pixbuf(pixbuf_, 15, 5)
			else
				-- for raster image
				cr:scale(aspect, aspect)
				cr:set_source_surface(self._image, 15, 5)
				cr:scale(1/aspect, 1/aspect) -- fix this !!!
			end
		else
			cr:set_source_surface(self._image, 15, 5)
		end

		-- set icon color if need
        local pattern = get_current_pattern(cr)
        cr:scale(aspect, aspect) -- fix this !!!
        local clr = data.state.active and style.color.main
                    or (n == 0 or data.state.minimized) and style.color.gray
                    or style.color.icon
        cr:set_source(color(clr))
        cr:scale(1/aspect, 1/aspect) -- fix this !!!
        cr:mask(pattern, 0, 0)

		cr:restore()

		-- occupied mark
		local x = (width - style.point.width) / 2

		if n > 0 then
			local l = (style.point.width - (n - 1) * style.point.dx) / n

			for i = 1, n do
				local cl = data.state.list[i].focus and style.color.main or
				           data.state.list[i].urgent and style.color.urgent or
				           data.state.list[i].minimized and style.show_min and style.color.gray or
				           style.color.icon
				cr:set_source(color(cl))
				cr:rectangle(x + (i - 1) * (style.point.dx + l), style.point.gap, l, style.point.height)
				cr:fill()
			end
		else
			cr:set_source(color(style.color.gray))
			cr:rectangle((width - style.point.width) / 2, style.point.gap, style.point.width, style.point.height)
			cr:fill()
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call blueicontag module as function
-----------------------------------------------------------------------------------------------------------------------
function blueicontag.mt:__call(...)
	return blueicontag.new(...)
end

return setmetatable(blueicontag, blueicontag.mt)
