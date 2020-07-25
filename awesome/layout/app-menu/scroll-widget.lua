local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local mutils = require('menubar.utils')
local inspect = require('library.inspect')
local dpi = beautiful.xresources.apply_dpi
local icons = require('theme.icons')

local scroll_widget = function (s, column_width, close_menu_panel, context_menu)

  local highlight_color = '#aaaaaa11'
  local highlight_border_color = '#cccccc11'
  local fg_color = '#fafafa'

  column_width = column_width - 60
  local own_widget = wibox.widget {}
  local offset_x, offset_y = 0, 0

  local scrollHeight = 0
  local apps = {}

  local application_list = wibox.widget {
    spacing = dpi(12);
    layout = wibox.layout.fixed.vertical
  }

  local active_widget = nil

  local string_split = function(inputstr, sep)
    if sep == nil then
            sep = ";"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
  end

  local application_list_item = function(app_name)
    --print("/usr/share/applications/"..app_name)
    local file, err = io.open("/usr/share/applications/"..app_name,"r")
    if err then
      print(err)
    end
    local desktop_name = nil
    local icon_path = nil
    local display = true
    local exec = ''
    local keywords = nil
    if file then
      local app_desktop_file = file:read("*a");
      desktop_name = string.match(app_desktop_file, 'Name=(.-)\n')
      icon_path = mutils.lookup_icon_uncached(string.match(app_desktop_file, 'Icon=(.-)\n'))
      if not icon_path then
        icon_path = icons.default_app
      end
      local d = string.match(app_desktop_file, 'NoDisplay=(.-)\n')
      if d == 'true' then
        display = false
      end
      keywords = string.match(app_desktop_file, 'Keywords=(.-)\n')
      if keywords ~= nil then
        keywords = string_split(keywords, ';')
      end
      if string.sub( app_name, 1,  12) == 'in.lsp_plug.' then
        display = false
      end
      exec = string.match(app_desktop_file, '\nExec=(.-)\n')
      if exec ~= '' and exec ~= nil then
        exec = string.gsub(exec,' %%u','')
        exec = string.gsub(exec,' %%U','')
        exec = string.gsub(exec,' %%f','')
        exec = string.gsub(exec,' %%F','')
      end
      --print(exec)
      file:close()
    end
    if display then
      local w = wibox.widget {
        {
          {
            {
              widget = wibox.widget.imagebox,
              image = (icon_path or nil),
              resize = true,
              forced_height = dpi(26),
              forced_width = dpi(26)
            },
            {
              markup = '<span font="IBM Plex Sans 10" foreground="'..fg_color..'">'.. (desktop_name or app_name) ..'</span>',
              valign = 'center',
              align = 'left',
              widget = wibox.widget.textbox,
              forced_height = dpi(26),
              forced_width = column_width
            },
            nil,
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(18)
          },
          widget = wibox.container.margin,
          margins = dpi(8)
        },
        bg = '#00000000',
        widget = wibox.container.background,
        border_width = dpi(1),
        border_color = '#ffffff00',
        forced_height = dpi(40),
        shape = function(cr, w, h)
          gears.shape.rounded_rect(cr, w, h, dpi(2))
        end,
      }

      w:connect_signal('button::press', function(self, lx, ly, button)
        if button == 1 then
          awful.spawn(exec, false)
          context_menu:hide()
          close_menu_panel()
        elseif button == 3 then
          print("Open Context Menu")
          context_menu:show((desktop_name or app_name), exec, icon_path)
        end
      end)

      local app_entry = {
        w = w,
        name = (desktop_name or app_name),
        keywords = keywords,
        executable = exec,
        display = true
      }

      w:connect_signal('mouse::enter', function()
        if active_widget then
          active_widget.w.bg = '#00000000'
          active_widget.w.border_color = '#ffffff00'
          active_widget = nil
        end
        w.bg = highlight_color
        w.border_color = highlight_border_color
        active_widget = app_entry
      end)

      w:connect_signal('mouse::leave', function() 
        w.bg = '#00000000'
        w.border_color = '#ffffff00'
        active_widget = nil
      end)

      table.insert( apps, app_entry)
      table.sort(apps, function (a, b)
        return string.upper(a.name) < string.upper(b.name)
      end)

      application_list = wibox.widget {
        spacing = dpi(15);
        layout = wibox.layout.fixed.vertical
      }

      local last_letter = ""
      scrollHeight = 0

      for k, v in pairs(apps) do
        local l = string.upper(string.sub(v.name, 1, 1))
        if l ~= last_letter then
          application_list:add(wibox.widget {
            {
              markup = '<span font="IBM Plex Sans 13" foreground="'..fg_color..'">'.. string.upper(l) ..'</span>',
              valign = 'bottom',
              align = 'left',
              widget = wibox.widget.textbox,
              forced_height = dpi(35),
              forced_width = column_width
            },
            widget = wibox.container.margin,
            top = dpi(5),
            bottom = dpi(5),
            left = dpi(15),
            forced_height = dpi(55)
          })
          scrollHeight = scrollHeight + 67
          last_letter = l
        end
        scrollHeight = scrollHeight + 60
        application_list:add(v.w)
      end
      own_widget:emit_signal("widget::layout_changed")
    end
  end

  function own_widget:layout(context, width, height)
      -- No idea how to pick good widths and heights for the inner widget.
      return { wibox.widget.base.place_widget_at(application_list, offset_x, offset_y, column_width, dpi(scrollHeight + 67)) }
  end

  own_widget:buttons(
      awful.util.table.join(
          awful.button(
              {},
              4,
              function()
                if offset_y <= dpi(-30) then
                    offset_y = offset_y + dpi(30)
                end
                own_widget:emit_signal("widget::layout_changed")
              end
          ),
          awful.button(
              {},
              5,
              function()
                if offset_y >= dpi(-scrollHeight+30+500) then
                  offset_y = offset_y - dpi(30)
                end
                own_widget:emit_signal("widget::layout_changed")
              end
          )
      )
  )
  local scroll_widget_list = wibox.widget {
    {
      widget = wibox.container.margin,
      left = dpi(20),
      right = dpi(20),
      top = dpi(5),
      bottom = dpi(5),
      {
        own_widget,
        bg = '#00000000',
        shape = function(cr, w, h)
          gears.shape.partially_rounded_rect(cr, w, h, false, true, false, false, beautiful.groups_radius)
        end,
        widget = wibox.container.background
      }
    },
    widget = wibox.container.constraint,
    width = column_width,
    height = dpi(500),
    strategy = 'exact'
  }

  local l_letter = ''

  function scroll_widget_list:update_applications()
    apps = {}
    scrollHeight = 0
    offset_x, offset_y = 0, 0
    local dir = "/usr/share/applications/"
    awful.spawn.with_line_callback('find "'..dir..'" -name "*.desktop"', {
      stdout = function(file)
        local name = file:gsub("/usr/share/applications/","")
        application_list_item(name)
      end,
      stderr = function(line)
          naughty.notification { message = "ERR:"..line}
      end,
    })
  end
  --scroll_widget_list:update_applications()

  local previousPacmanStats = ''
  local update_interval = 360 -- update every 5 minutes for now, F5 can be pressed to manually refresh list
  awful.widget.watch(
    [[
    sh -c "
    pacman -Qs | wc
    "]],
    update_interval,
    function(widget, stdout)
      if stdout ~= previousPacmanStats then
        previousPacmanStats = stdout
        print("Pacman Update Detected: " .. stdout)
        scroll_widget_list:update_applications()
      end
    end
  )

  function scroll_widget_list:move_select_down()
    if active_widget then
      for k, v in pairs(apps) do
        if active_widget.executable == v.executable then
          if apps[k+1] then
            for a=1, #apps do
              if apps[k+a] and apps[k+a].display then
                active_widget.w.bg = '#00000000'
                active_widget.w.border_color = '#ffffff00'
                active_widget = apps[k+a]
                active_widget.w.bg = highlight_color
                active_widget.w.border_color = highlight_border_color
                local l = string.upper(string.sub(active_widget.name, 1, 1))
                print(l.." "..l_letter)
                if l ~= l_letter then
                  if offset_y >= dpi(-scrollHeight+117+500) then
                    offset_y = offset_y - dpi(117)
                  end
                  l_letter = l
                else
                  if offset_y >= dpi(-scrollHeight+55+500) then
                    offset_y = offset_y - dpi(55)
                  end
                end
                return own_widget:emit_signal("widget::layout_changed")
              end
            end
          end
          return
        end
      end
    else
      for k, v in pairs(apps) do
        active_widget = v
        return
      end
    end
  end


  function scroll_widget_list:move_select_up()
    if active_widget then
      for k, v in pairs(apps) do
        if active_widget.executable == v.executable then
          if apps[k-1] then
            for a=1, #apps do
              if apps[k-a] and apps[k-a].display then
                active_widget.w.bg = '#00000000'
                active_widget.w.border_color = '#ffffff00'
                active_widget = apps[k-a]
                active_widget.w.bg = highlight_color
                active_widget.w.border_color = highlight_border_color
                local l = string.upper(string.sub(v.name, 1, 1))
                if l ~= l_letter then
                  l_letter = l
                  if offset_y <= dpi(-117) then
                    offset_y = offset_y + dpi(117)
                  end
                else
                  if offset_y <= dpi(-55) then
                    offset_y = offset_y + dpi(55)
                  end
                end
                return own_widget:emit_signal("widget::layout_changed")
              end
            end
          end
          return
        end
      end
    else
      for k, v in pairs(apps) do
        active_widget = v
        return
      end
    end
  end

  function scroll_widget_list:spawn_on_enter()
    if active_widget then
      awful.spawn(active_widget.executable, false)
      close_menu_panel()
    end
  end

  function scroll_widget_list:filter(app_name)
    if active_widget then
      active_widget.w.bg = '#00000000'
      active_widget.w.border_color = '#ffffff00'
    end
    active_widget = nil
    application_list = wibox.widget {
      spacing = dpi(15);
      layout = wibox.layout.fixed.vertical
    }

    local last_letter = ""
    scrollHeight = 0

    offset_y = 0
    own_widget:emit_signal("widget::layout_changed")

    for k, v in pairs(apps) do
      local match_found = false
      v.display = false
      if string.find(string.upper(v.name), string.upper(app_name or '')) or app_name == '' or app_name == nil then
        match_found = true
      elseif v.keywords then
        -- check if any keywords match
        for key, keyword in pairs(v.keywords) do
          if string.find(string.upper(keyword), string.upper(app_name or '')) then
            match_found = true
          end
        end
      end
      if match_found then
        v.display = true
        local l = string.upper(string.sub(v.name, 1, 1))
        if l ~= last_letter then
          application_list:add(wibox.widget {
            {
              markup = '<span font="IBM Plex Sans 12" foreground="'..fg_color..'">'.. string.upper(l) ..'</span>',
              valign = 'bottom',
              align = 'left',
              widget = wibox.widget.textbox,
              forced_height = dpi(35),
              forced_width = column_width
            },
            widget = wibox.container.margin,
            top = dpi(5),
            bottom = dpi(5),
            left = dpi(15),
            forced_height = dpi(55)
          })
          scrollHeight = scrollHeight + 67
          last_letter = l
        end
        scrollHeight = scrollHeight + 60
        application_list:add(v.w)
        if not active_widget then
          active_widget = v
          v.w.bg = highlight_color
          v.w.border_color = highlight_border_color
        end
      end
    end
    own_widget:emit_signal("widget::layout_changed")
  end

  return scroll_widget_list
end

return scroll_widget