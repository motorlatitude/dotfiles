local awful = require('awful')
local modkey = require('configuration.keys.mod').modKey
local gears = require('gears')

return awful.util.table.join(
	awful.button(
		{},
		1,
		function(c)
			_G.client.focus = c
			c:raise()
			for s in screen do
				if s.app_menu_panel then
					s.app_menu_panel:HideDashboard()
				end
				if s.app_menu_context_menu then
					s.app_menu_context_menu:hide()
				end
			end
		end
	),
	awful.button({modkey}, 1, awful.mouse.client.move),
	awful.button({modkey}, 3, awful.mouse.client.resize),
	awful.button(
		{modkey},
		4,
		function()
			awful.layout.inc(1)
		end
	),
	awful.button(
		{modkey},
		5,
		function()
			awful.layout.inc(-1)
		end
	)
)
