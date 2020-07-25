local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local icons = require('theme.icons')
local json = require('cjson')

local dpi = beautiful.xresources.apply_dpi

local am_shortcuts = function(s, menu_panel_column, panel_margins)

  local height = dpi(215)

  local highlight_color = '#aaaaaa11'
  local highlight_border_color = '#cccccc11'
  local fg_color = '#ffffffff'


  local pinned_apps_table = {
    ["apps"] = {}
  }

  local get_pinned_apps = function()
    file = io.open(os.getenv("HOME").."/.config/awesome/pinned_apps.conf","r")
    if file then 
      local pinned_apps = file:read("a*")
      if pinned_apps == "" then
        pinned_apps_table = {
          ["apps"] = {}
        }
      else
        pinned_apps_table = json.decode(pinned_apps)
      end
      file:close()
      --print(docked_apps_table)
      return pinned_apps_table
    else
      return {
        ["apps"] = {}
      }
    end
  end

  local create_shortcut_button = function(name, icon, cmd)
		local w = wibox.widget {
			{
        {
          {
            widget = wibox.widget.imagebox,
            image = icon,
            forced_height = dpi(44),
            forced_width = dpi(44),
            resize = true,
          },
          widget = wibox.container.margin,
          left = dpi(22),
          right = dpi(22),
          top = dpi(8),
          bottom = dpi(8),
          forced_height = dpi(50),
          forced_width = dpi(80)
        },
        {
          {
            widget = wibox.widget.textbox,
            markup = '<span font="IBM Plex Sans 8" foreground="#ffffff">' .. name .. '</span>',
            align = 'center',
            valign = 'center'
          },
          widget = wibox.container.margin,
          margins = dpi(5),
          forced_height = dpi(25),
          forced_width = dpi(80)
        },
        layout = wibox.layout.fixed.vertical,
			},
			bg = '#11111100',
			forced_width = dpi(80),
			forced_height = dpi(80),
      widget = wibox.container.background,
      border_width = dpi(1),
      border_color = '#00000000',
			shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, dpi(5))
			end,
    }

    w:connect_signal("mouse::enter", function()
      w.bg = highlight_color
      w.border_color = highlight_border_color
    end)

    w:connect_signal("mouse::leave", function()
      w.bg = '#aaaaaa00'
      w.border_color = '#aaaaaa00'
    end)

    return w
  end


  local shortcuts_grid = wibox.widget {
    layout = wibox.layout.grid,
    forced_num_cols = 4,
    forced_num_rows = 2,
    spacing = dpi(16),
  }

  local apps = get_pinned_apps()
  for i=1, #pinned_apps_table["apps"] do
    local item = pinned_apps_table["apps"][i]
    if item then
      shortcuts_grid:add(create_shortcut_button(item.name, item.icon, item.cmd))
    end
  end

  s.am_shortcuts= awful.popup {
    widget = {
      {
        {
          shortcuts_grid,
          widget = wibox.container.margin,
          margins = dpi(20)
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

	awful.placement.top_left(s.am_shortcuts, {margins = {
		left = panel_margins*3 + dpi(350) + dpi(60),
		top = s.geometry.y + s.geometry.height - dpi(507) - dpi(53)
		}, parent = s
  })

  function s.am_shortcuts:show()
    s.am_shortcuts.visible = true
  end

  function s.am_shortcuts:hide()
    s.am_shortcuts.visible = false
  end

  return s.am_shortcuts

end

return am_shortcuts