local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local icons = require('theme.icons')

local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'configuration/user-profile/'
local apps = require('configuration.apps')

local dpi = beautiful.xresources.apply_dpi

local profile = function(s, menu_panel_column, panel_margins)
  
  local height = dpi(185)

	local greeting_widget = wibox.widget {
		markup = '<span font="IBM Plex Sans Bold 12" foreground="#ffffff"></span>',
		valign = 'center',
		align = 'center',
		widget = wibox.widget.textbox,
	}

	awful.spawn.easy_async_with_shell(
		"printf \"$(whoami)\"",
		function(stdout) 
			local stdout = stdout:gsub('%\n', '')
			greeting_widget:set_markup('<span font="IBM Plex Sans Bold 12" foreground="#ffffff">Good morning, ' .. stdout .. '</span>')
		end
	)


	local kernel_widget = wibox.widget {
		markup = '<span font="IBM Plex Mono 12" foreground="#ffffff"></span>',
		valign = 'center',
		align = 'center',
		widget = wibox.widget.textbox,
	}

	awful.spawn.easy_async_with_shell(
		"uname -r",
		function(stdout) 
			local stdout = stdout:gsub('%\n', '')
			kernel_widget:set_markup('<span font="IBM Plex Mono 10" foreground="#aaaaaa">' .. stdout .. '</span>')
		end
  )
  

	local profile_imagebox = wibox.widget {
		image = widget_icon_dir .. 'default.svg',
		resize = true,
		forced_height = dpi(90),
		forced_width = dpi(90),
		clip_shape = function(cr, w, h)
			gears.shape.circle(cr, dpi(90), dpi(90), dpi(90)/2)
		end,
		widget = wibox.widget.imagebox
	}

	awful.spawn.easy_async_with_shell(
		apps.bins.update_profile,
		function(stdout)
			stdout = stdout:gsub('%\n','')
			if not stdout:match("default") then
				print("Profile Picture Path: " .. stdout)
				profile_imagebox:set_image(stdout)
				profile_imagebox:set_resize(true)
			else
				profile_imagebox:set_image(widget_icon_dir .. 'default.svg')
				profile_imagebox:set_resize(true)
			end
		end
	)

	local profile_picture_left = dpi(150)

  s.am_profile_info = awful.popup {
    widget = {
      {
        profile_imagebox,
        widget = wibox.container.margin,
        left = profile_picture_left,
        forced_height = dpi(90),
        forced_width = dpi(90),
      },
      {
        greeting_widget,
        widget = wibox.container.margin,
        top = dpi(8)
      },
      {
        kernel_widget,
        widget = wibox.container.margin,
        margins = dpi(8),
      },
      layout = wibox.layout.fixed.vertical
    },
    screen = s,
		type = 'utility',
		visible = false,
		ontop = true,
		maximum_height = height,
		minimum_height = height,
		minimum_width = menu_panel_column + dpi(40),
		bg = beautiful.transparent,
		fg = beautiful.fg_normal,
    shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, dpi(5))
    end,
	}

	awful.placement.top_left(s.am_profile_info, {margins = {
		left = panel_margins*3 + dpi(350) + dpi(60),
		top = s.geometry.y + s.geometry.height - dpi(700) - dpi(33)
		}, parent = s
  })
  
  function s.am_profile_info:show() 
    s.am_profile_info.visible = true
  end
  
  function s.am_profile_info:hide() 
    s.am_profile_info.visible = false
  end

  return s.am_profile_info 

end

return profile