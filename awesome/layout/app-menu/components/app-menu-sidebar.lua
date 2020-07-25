local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local icons = require('theme.icons')

local dpi = beautiful.xresources.apply_dpi

local sidebar = function(s, menu_panel_height, panel_margins)
  
  local height = dpi(635)

  local create_sidebar_button = function(button_type)
		local w = wibox.widget {
			{
				{
					widget = wibox.widget.imagebox,
					image = icons[button_type],
					forced_height = dpi(16),
					forced_width = dpi(16),
					resize = true,
				},
				widget = wibox.container.margin,
				margins = dpi(12)
			},
			bg = '#11111100',
			forced_width = dpi(40),
			forced_height = dpi(40),
			opacity = 0.7,
			widget = wibox.container.background,
			shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, dpi(5))
			end,
    }

    w:connect_signal("mouse::enter", function()
      w.bg = '#aaaaaa33'
    end)

    w:connect_signal("mouse::leave", function()
      w.bg = '#aaaaaa00'
    end)

    return w
  end

  s.app_menu_sidebar = awful.popup {
    widget = {
      {
        {
          {
            {
              widget = wibox.container.margin,
              top = dpi(465)
            },
            create_sidebar_button('files'),
            create_sidebar_button('settings'),
            create_sidebar_button('power_off'),
            spacing = dpi(10),
            layout = wibox.layout.fixed.vertical
          },
          widget = wibox.container.margin,
          margins = dpi(10)
        },
        bg = '#111111cc',
        shape = function(cr, w, h)
          gears.shape.rounded_rect(cr, w, h, dpi(5))
        end,
        forced_width = dpi(60),
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
		minimum_width = dpi(60),
		height = s.geometry.height,
		bg = beautiful.transparent,
		fg = beautiful.fg_normal,
    shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, dpi(5))
    end,
	}

	awful.placement.top_left(s.app_menu_sidebar, {margins = {
		left = panel_margins,
		top = s.geometry.y + s.geometry.height - height - dpi(53)
		}, parent = s
  })
  
  function s.app_menu_sidebar:show() 
    s.app_menu_sidebar.visible = true
  end
  
  function s.app_menu_sidebar:hide() 
    s.app_menu_sidebar.visible = false
  end

  return s.app_menu_sidebar 

end

return sidebar