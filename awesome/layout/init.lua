local awful = require('awful')
local top_panel = require('layout.top-panel')
local bottom_panel = require('layout.bottom-panel')
local floating_panel = require('layout.floating-panel')
local app_menu_panel = require('layout.app-menu');
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

-- Create a wibox panel for each screen and add it
screen.connect_signal("request::desktop_decoration", function(s)
	s.top_panel = top_panel(s)
	s.bottom_panel = bottom_panel(s)
	s.floating_panel = floating_panel(s)
	s.floating_panel_show_again = false
	s.app_menu_panel = app_menu_panel(s)
	s.app_menu_panel_show_again = false
	s.padding = {top = dpi(32), bottom = dpi(18)}

	awesome.connect_signal("update::taskbar", function()
		s.top_panel.visible = false -- TODO: find a better solution if there's a performance impact
		s.top_panel = top_panel(s)
	end)

	for s in screen do
		s.workarea = {
			x = s.geometry.x + 3,
			y = s.geometry.y + 30,
			width = s.geometry.width - 6,
			height = s.geometry.height - 70
		}
	end

end)


-- Hide bars when app go fullscreen
function updateBarsVisibility()
	for s in screen do
		focused = awful.screen.focused()
		if s.selected_tag then
			local fullscreen = s.selected_tag.fullscreenMode
			-- Order matter here for shadow
			s.top_panel.visible = not fullscreen
			s.bottom_panel.visible = not fullscreen
			if s.floating_panel then
				if fullscreen and focused.floating_panel.visible then
					focused.floating_panel:toggle()
					focused.floating_panel_show_again = true
				elseif not fullscreen and not focused.floating_panel.visible and focused.floating_panel_show_again then
					focused.floating_panel:toggle()
					focused.floating_panel_show_again = false
				end
			end
			if s.app_menu_panel then
				if fullscreen and focused.app_menu_panel.visible then
					focused.app_menu_panel:toggle()
					focused.app_menu_panel_show_again = true
				elseif not fullscreen and not focused.app_menu_panel.visible and focused.app_menu_panel_show_again then
						focused.app_menu_panel:toggle()
						focused.app_menu_panel_show_again = false
				end
			end
		end
	end
end

tag.connect_signal(
	'property::selected',
	function(t)
		updateBarsVisibility()
	end
)

client.connect_signal(
	'property::fullscreen',
	function(c)
		if c.first_tag then
			c.first_tag.fullscreenMode = c.fullscreen
			c.x = c.x + 3
			c.y = c.y + 10
			c.width = c.width - 6
			c.height = c.height - 30
		end
		updateBarsVisibility()
	end
)

client.connect_signal(
	'unmanage',
	function(c)
		if c.fullscreen then
			c.screen.selected_tag.fullscreenMode = false
			updateBarsVisibility()
		end
	end
)
