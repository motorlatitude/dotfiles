local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')

local dpi = beautiful.xresources.apply_dpi
local clickable_container = require('widget.clickable-container')

local tag_list = require('widget.tag-list')

local bottom_panel = function(s)

	local layout_box = function(s)
		local layoutbox = wibox.widget {
			{
				awful.widget.layoutbox(s),
				margins = dpi(7),
				widget = wibox.container.margin
			},
			widget = clickable_container
		}
		layoutbox:buttons(
			awful.util.table.join(
				awful.button(
					{},
					1,
					function()
						awful.layout.inc(1)
					end
				),
				awful.button(
					{},
					3,
					function()
						awful.layout.inc(-1)
					end
				),
				awful.button(
					{},
					4,
					function()
						awful.layout.inc(1)
					end
				),
				awful.button(
					{},
					5,
					function()
						awful.layout.inc(-1)
					end
				)
			)
		)
		return layoutbox
	end

	local build_widget = function(widget)
		return wibox.widget {
			{
				widget,
				bg = beautiful.transparent,
				shape = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, dpi(6))
				end,
				widget = wibox.container.background
			},
			top = dpi(10),
			bottom = dpi(10),
			widget = wibox.container.margin
		}
	end
	--s.bluetooth   	= build_widget(require('widget.bluetooth')())
	--s.network        	= build_widget(require('widget.network')())
	--s.battery     	= build_widget(require('widget.battery')())
	--s.search      	= require('widget.search-apps')()
	--s.music       	= require('widget.music')()
	s.volume = require('widget.volume.volume-slider')
	s.cpu = require('widget.cpu.cpu-meter')
	s.spotify 	= require('widget.spotify')()
	s.end_session	= require('widget.end-session')()
	
	local separator =  wibox.widget {
		orientation = 'vertical',
		forced_height = dpi(1),
		forced_width = dpi(1),
		span_ratio = 0.55,
		widget = wibox.widget.separator
	}

	local bottom_panel_height = dpi(32)
	local bottom_panel_margins = dpi(5)

	local panel = awful.popup {
		widget = {
			{
				layout = wibox.layout.align.horizontal,
				width = s.geometry.width,
				expand = "inside",
				{
					{
						{
							tag_list(s),
							bg = '#ffffffee',
							widget = wibox.container.background,
							shape = function(cr, w, h)
								gears.shape.rounded_rect(cr, w, h, dpi(4))
							end,
						},
						{
							s.spotify,
							bg = '#000000ee',
							widget = wibox.container.background,
							shape = function(cr, w, h)
								gears.shape.rounded_rect(cr, w, h, dpi(4))
							end,
						},
						spacing = dpi(10),
						layout = wibox.layout.fixed.horizontal
					},
					widget = wibox.container.margin,
					left = dpi(8)
				},
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(5),
				},
				--require('widget.xdg-folders'),
				{ {
						{
							s.volume,
							bg = '#ffffffee',
							widget = wibox.container.background,
							shape = function(cr, w, h)
								gears.shape.rounded_rect(cr, w, h, dpi(4))
							end,
						},
						{
							s.end_session,
							bg = '#000000ee',
							widget = wibox.container.background,
							shape = function(cr, w, h)
								gears.shape.rounded_rect(cr, w, h, dpi(4))
							end,
						},
						layout = wibox.layout.fixed.horizontal,
						spacing = dpi(10)
					},
					right = dpi(5),
					widget = wibox.container.margin,
				},
			},
			bg = beautiful.transparent,
			forced_width = s.geometry.width,
			widget = wibox.container.background
		},
		type = 'utility',
		screen = s,
		ontop = true,
		visible = true,
		width = s.geometry.width,
		height = bottom_panel_height,
		maximum_height = bottom_panel_height,
		placement = function (c)
			return awful.placement.top(c,{
				margins = 8
			})
		end,
		shape = gears.shape.rectangle,
		bg = beautiful.transparent
	}

	panel:struts
	{
		bottom = bottom_panel_height
	}

	return panel
end


return bottom_panel
