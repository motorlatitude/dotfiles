local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local mutils = require('menubar.utils')
local inspect = require('library.inspect')
local dpi = beautiful.xresources.apply_dpi
local icons = require('theme.icons')
local json = require('cjson')

local dpi = beautiful.xresources.apply_dpi

local ctx_menu = function(s)

  local height = dpi(90)

  local active_class = nil
  local active_cmd = nil
  local active_icon_path = nil

  local context_menu_options = wibox.widget {
    spacing = dpi(12);
    layout = wibox.layout.fixed.vertical
  }


  local app_menu_context_menu = awful.popup {
    widget = {
      {
        context_menu_options,
        widget = wibox.container.margin,
        margins = dpi(10)
      },
      bg = '#22222244',
      shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, dpi(5))
      end,
      forced_width = dpi(200),
      forced_height = height,
      widget = wibox.container.background
    },
    screen = s,
		type = 'dock',
		visible = false,
		ontop = true,
		maximum_height = height,
		minimum_height = height,
		minimum_width = dpi(200),
		bg = beautiful.transparent,
		fg = beautiful.fg_normal,
    shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, dpi(5))
    end,
  }

  local dock_option = wibox.widget {
    markup = '<span font="IBM Plex Sans 10" foreground="#eeeeee">Dock (?)</span>',
    valign = 'center',
    align = 'left',
    widget = wibox.widget.textbox,
    forced_height = dpi(15),
    forced_width = dpi(190)
  }


  --[[  DOCK APPS  ]]
  local docked_apps_table = {
    ["apps"] = {}
  }

  local is_class_docked = function(c)
    file = io.open(os.getenv("HOME").."/.config/awesome/docked_apps.conf","a+")
    local docked_apps = file:read("a*");
    local already_docked = false
    if docked_apps == "" then
      docked_apps_table = {
        ["apps"] = {}
      }
    else
      docked_apps_table = json.decode(docked_apps);
      for i=1, #docked_apps_table["apps"] do
        local item = docked_apps_table["apps"][i]
        if item["name"] == c then
          already_docked = true
        end
      end
    end
    file:close()
    return already_docked
  end

  local delete_docked_class  = function(name)
    file = io.open(os.getenv("HOME").."/.config/awesome/docked_apps.conf","a+")
    local docked_apps = file:read("a*");
    file:close()
    file = io.open(os.getenv("HOME").."/.config/awesome/docked_apps.conf","w")
    local already_docked = false
    if docked_apps == "" then
      docked_apps_table = {
        ["apps"] = {}
      }
    else
      docked_apps_table = json.decode(docked_apps)
      for i=1, #docked_apps_table["apps"] do
        local item = docked_apps_table["apps"][i]
        if item and item["name"] == name then
          table.remove(docked_apps_table["apps"], i)
          file:write(json.encode(docked_apps_table))
        end
      end
    end
    file:close()
    awesome.emit_signal("update::taskbar")
  end

  local append_docked_class = function(c)
    local already_docked = is_class_docked(c)
    file = io.open(os.getenv("HOME").."/.config/awesome/docked_apps.conf","w")
    print("Append Docked Item: " .. (not already_docked and 'true' or 'false'))
    print(c .. " -> " .. active_cmd)
    if not already_docked then
      if c and active_cmd then
        --print(cmd)
        table.insert(docked_apps_table["apps"],{
          ["name"] = c,
          ["cmd"] = active_cmd,
          ["icon"] = active_icon_path
        })
        print(inspect(docked_apps_table))
        file:write(json.encode(docked_apps_table))
        file:close()
        awesome.emit_signal("update::taskbar")
      end
    end
  end


  --[[  PINNED TO START APPS  ]]
  local pinned_apps_table = {
    ["apps"] = {}
  }

  local is_class_pinned = function(c)
    file = io.open(os.getenv("HOME").."/.config/awesome/pinned_apps.conf","a+")
    local pinned_apps = file:read("a*");
    local already_pinned = false
    if pinned_apps == "" then
      pinned_apps_table = {
        ["apps"] = {}
      }
    else
      pinned_apps_table = json.decode(pinned_apps);
      for i=1, #pinned_apps_table["apps"] do
        local item = pinned_apps_table["apps"][i]
        if item and item["name"] == c then
          already_pinned = true
        end
      end
    end
    file:close()
    return already_pinned
  end

  local delete_pinned_class  = function(name)
    file = io.open(os.getenv("HOME").."/.config/awesome/pinned_apps.conf","a+")
    local pinned_apps = file:read("a*");
    file:close()
    file = io.open(os.getenv("HOME").."/.config/awesome/pinned_apps.conf","w")
    local already_pinned = false
    if pinned_apps == "" then
      pinned_apps_table = {
        ["apps"] = {}
      }
    else
      pinned_apps_table = json.decode(pinned_apps)
      for i=1, #pinned_apps_table["apps"] do
        local item = pinned_apps_table["apps"][i]
        if item and item["name"] == name then
          table.remove(pinned_apps_table["apps"], i)
          file:write(json.encode(pinned_apps_table))
        end
      end
    end
    file:close()
    awesome.emit_signal("update::taskbar")
  end

  local append_pinned_class = function(c)
    local already_docked = is_class_pinned(c)
    file = io.open(os.getenv("HOME").."/.config/awesome/pinned_apps.conf","w")
    print("Append pinned Item: " .. (not already_pinned and 'true' or 'false'))
    print(c .. " -> " .. active_cmd)
    if not already_pinned then
      if c and active_cmd then
        --print(cmd)
        table.insert(pinned_apps_table["apps"],{
          ["name"] = c,
          ["cmd"] = active_cmd,
          ["icon"] = active_icon_path
        })
        print(inspect(pinned_apps_table))
        file:write(json.encode(pinned_apps_table))
        file:close()
        awesome.emit_signal("update::taskbar")
      end
    end
  end

  local pin_to_start = wibox.widget {
    {
      {
        markup = '<span font="IBM Plex Sans 10" foreground="#eeeeee">Pin To Start</span>',
        valign = 'center',
        align = 'left',
        widget = wibox.widget.textbox,
        forced_height = dpi(15),
        forced_width = dpi(190)
      },
      widget = wibox.container.margin,
      top = dpi(5),
      bottom = dpi(5),
      left = dpi(15),
      forced_height = dpi(30)
    },
    bg = '#00000000',
    widget = wibox.container.background,
    forced_height = dpi(30),
    shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, dpi(2))
    end,
  }

  pin_to_start:connect_signal('mouse::enter', function()
    pin_to_start.bg = '#42A5F5FF'
  end)

  pin_to_start:connect_signal('mouse::leave', function()
    pin_to_start.bg = '#00000000'
  end)

  pin_to_start:connect_signal('button::press', function(self, lx, ly, button)
    if button == 1 then
      print("Pin To Start")
      append_pinned_class(active_class)
      app_menu_context_menu:hide()
    end
  end)

  local add_to_dock = wibox.widget {
    {
      dock_option,
      widget = wibox.container.margin,
      top = dpi(5),
      bottom = dpi(5),
      left = dpi(15),
      forced_height = dpi(30)
    },
    bg = '#00000000',
    widget = wibox.container.background,
    forced_height = dpi(30),
    shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, dpi(2))
    end,
  }

  add_to_dock:connect_signal('mouse::enter', function()
    add_to_dock.bg = '#42A5F5FF'
  end)

  add_to_dock:connect_signal('mouse::leave', function()
    add_to_dock.bg = '#00000000'
  end)

  function app_menu_context_menu:hide()
    active_class = nil
    active_cmd = nil
    active_icon_path = nil
    app_menu_context_menu.visible = false
  end

  add_to_dock:connect_signal('button::press', function(self, lx, ly, button)
    if button == 1 then
      if is_class_docked(active_class) then
        print("Remove from Docked Apps")
        delete_docked_class(active_class)
      else
        print("Add to Docked Apps")
        append_docked_class(active_class)
      end
      app_menu_context_menu:hide()
    end
  end)

  context_menu_options:add(pin_to_start)
  context_menu_options:add(add_to_dock)


  function app_menu_context_menu:show(class, command, icon_path)
    active_class = class  
    active_cmd = command
    active_icon_path = icon_path

    dock_option:set_markup('<span font="IBM Plex Sans 10" foreground="#eeeeee">' .. (is_class_docked(active_class) and 'Undock' or 'Dock') .. '</span>')

    local mouse_coords = mouse.coords()

    awful.placement.top_left(app_menu_context_menu, {margins = {
      left = mouse_coords.x - s.geometry.x,
      top = s.geometry.y + mouse_coords.y
      }, parent = s
    })

    app_menu_context_menu.visible = true
  end

  return app_menu_context_menu

end

return ctx_menu