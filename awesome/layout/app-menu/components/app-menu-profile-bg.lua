local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local icons = require('theme.icons')

local dpi = beautiful.xresources.apply_dpi

local profile_bg = function(s, menu_panel_column, panel_margins)
  
  local height = dpi(125)

  s.am_profilebg= awful.popup {
    widget = {
      {
        {
          widget = wibox.container.margin,
          margins = dpi(10)
        },
        bg = '#111111cc',
        shape = function(cr, w, h)
          gears.shape.rounded_rect(cr, w, h, dpi(5))
        end,
        forced_width = menu_panel_column + dpi(40),
        forced_height = height,
        widget = wibox.container.background
      },
      widget = wibox.container.margin,
      top = dpi(0)
    },
    screen = s,
		type = 'dock',
		visible = false,
		ontop = true,
		maximum_height = height,
		minimum_height = height,
		minimum_width = menu_panel_column + dpi(40),
		height = s.geometry.height,
		bg = beautiful.transparent,
		fg = beautiful.fg_normal,
    shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, dpi(5))
    end,
	}

	awful.placement.top_left(s.am_profilebg, {margins = {
		left = panel_margins*3 + dpi(350) + dpi(60),
		top = s.geometry.y + s.geometry.height - dpi(635) - dpi(53)
		}, parent = s
  })
  
  function s.am_profilebg:show() 
    s.am_profilebg.visible = true
  end
  
  function s.am_profilebg:hide() 
    s.am_profilebg.visible = false
  end

  return s.am_profilebg 

end

return profile_bg