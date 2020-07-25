
local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local icons = require('theme.icons')

local dpi = beautiful.xresources.apply_dpi

local app_list = function(s, sw, menu_panel_column, panel_margins)
  local height = dpi(635)

  s.app_list = awful.popup {
    widget = {
          sw,
          bg = '#111111cc',
          shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, dpi(5))
          end,
          forced_width = menu_panel_column,
          forced_height = dpi(430),
          widget = wibox.container.background
    },
    screen = s,
		type = 'dock',
		visible = false,
		ontop = true,
		maximum_height = height - dpi(53),
		minimum_height = height - dpi(53),
		minimum_width = menu_panel_column,
		height = s.geometry.height,
		bg = beautiful.transparent,
		fg = beautiful.fg_normal,
    shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, dpi(5))
    end,
	}

	awful.placement.top_left(s.app_list, {margins = {
		left = panel_margins*2 + dpi(60),
		top = s.geometry.y + s.geometry.height - height - dpi(53)
		}, parent = s
  })
  
  function s.app_list:show() 
    s.app_list.visible = true
  end
  
  function s.app_list:hide() 
    s.app_list.visible = false
  end

  return s.app_list

end

return app_list