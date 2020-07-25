local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local apps = require('configuration.apps')

local dpi = require('beautiful').xresources.apply_dpi
local clickable_container = require('widget.clickable-container')

local config_dir = gears.filesystem.get_configuration_dir()
local icons = require("theme.icons")
--   ▄▄▄▄▄           ▄      ▄                 
--   █    █ ▄   ▄  ▄▄█▄▄  ▄▄█▄▄   ▄▄▄   ▄ ▄▄  
--   █▄▄▄▄▀ █   █    █      █    █▀ ▀█  █▀  █ 
--   █    █ █   █    █      █    █   █  █   █ 
--   █▄▄▄▄▀ ▀▄▄▀█    ▀▄▄    ▀▄▄  ▀█▄█▀  █   █ 


-- The button in top panel

local return_button = function()

	local widget =
		wibox.widget {
		{
			id = 'icon',
			image = icons.menu,
			widget = wibox.widget.imagebox,
			resize = true
		},
		layout = wibox.layout.align.horizontal
	}

	local widget_button = wibox.widget {
		{
			{
				widget,
				layout = wibox.layout.align.vertical
			},
			margins = dpi(7),
			widget = wibox.container.margin
		},
		widget = clickable_container
	}

	widget_button:buttons(
		gears.table.join(
			awful.button(
				{},
				1,
				nil,
				function()
					local focused = awful.screen.focused()
					focused.app_menu_panel:toggle()
				end
			)
		)
	)

	return widget_button

end


return return_button
