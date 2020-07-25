local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local capi = {button = _G.button}
local gears = require('gears')
local menubar = require('menubar')
local mutils = require('menubar.utils')
local clickable_container = require('widget.clickable-container')
local icons = require('theme.icons')
local cairo = require('lgi').cairo
local json = require('cjson')

--local inspect = require('library.inspect')

--- sub string for utf8 format
-- @s the string need to be sub
-- @i index of start position
-- @j index of end position
local function utf8_sub(s, i, j)
    i = utf8.offset(s, i)
    j = (utf8.offset(s, j + 1) or j + 1) - 1
    return gears.string.xml_escape(s:sub(i, j))
end

--- Common method to create buttons.
-- @tab buttons
-- @param object
-- @treturn table
local function create_buttons(buttons, object)
	if buttons then
		local btns = {}
		for _, b in ipairs(buttons) do
			-- Create a proxy button object: it will receive the real
			-- press and release events, and will propagate them to the
			-- button object the user provided, but with the object as
			-- argument.
			local btn = capi.button {modifiers = b.modifiers, button = b.button}
			btn:connect_signal(
				'press',
				function()
					b:emit_signal('press', object)
				end
			)
			btn:connect_signal(
				'release',
				function()
					b:emit_signal('release', object)
				end
			)
			btns[#btns + 1] = btn
		end

		return btns
	end
end

local function list_update(w, buttons, label, data, objects)
	-- update the widgets, creating them if needed
	w:reset()
	for i, o in ipairs(objects) do
		local cache = data[o]
		local ib, cb, tb, cbm, bgb, tbm, ibm, tt, l, ll, bg_clickable
		if cache then
			tb = cache.tb
			bgb = cache.bgb
			tbm = cache.tbm
			ibm = cache.ibm
			tt  = cache.tt
		else
			tb = wibox.widget.textbox()
			cb = wibox.widget {
				{
					{
						image = icons.close,
						resize = true,
						widget = wibox.widget.imagebox
					},
					margins = dpi(4),
					widget = wibox.container.margin
				},
				widget = clickable_container
			}
			cb.shape = gears.shape.circle
			cbm = wibox.widget {
				-- 4, 8 ,12 ,12 -- close button
				cb,
				left = dpi(4),
				right = dpi(8),
				top = dpi(4),
				bottom = dpi(4),
				widget = wibox.container.margin
			}
			cbm:buttons(
				gears.table.join(
					awful.button(
						{},
						1,
						nil,
						function()
							o:kill()
						end
					)
				)
			)
			bg_clickable = clickable_container()
			bgb = wibox.container.background()
			tbm = wibox.widget {
				tb,
				left = dpi(4),
				right = dpi(4),
				widget = wibox.container.margin
			}
			ibm = wibox.widget {
                                {
                                    id = 'clienticon',
                                    widget = awful.widget.clienticon,
                                },
				left = dpi(10),
				bottom = dpi(10),
				right = dpi(10),
				top = dpi(10),
				widget = wibox.container.margin
			   }
			l = wibox.layout.fixed.horizontal()
			ll = wibox.layout.fixed.horizontal()

			-- All of this is added in a fixed widget
			l:fill_space(true)
			l:add(ibm)
			-- l:add(tbm)
			ll:add(l)
			-- ll:add(cbm)

			bg_clickable:set_widget(ll)
			-- And all of this gets a background
			bgb:set_widget(bg_clickable)

			l:buttons(create_buttons(buttons, o))

			-- Tooltip to display whole title, if it was truncated
			tt = awful.tooltip({
				objects = {ib},
				mode = 'outside',
				align = 'bottom',
				delay_show = 1,
			})

			data[o] = {
				tb = tb,
				bgb = bgb,
				tbm = tbm,
				ibm = ibm,
				tt  = tt
			}
		end

		local text, bg, bg_image, icon, args = label(o, tb)
		args = args or {}

		-- The text might be invalid, so use pcall.
		if text == nil or text == '' then
			tbm:set_margins(0)
		else
			-- truncate when title is too long
			local text_only = text:match('>(.-)<')
			if (text_only:len() > 24) then
				text = text:gsub('>(.-)<', '>' .. utf8_sub(text_only,1,21) .. '...<')
				tt:set_text(text_only)
				tt:add_to_object(tb)
			else
				tt:remove_from_object(tb)
			end
			if not tb:set_markup_silently(text) then
				tb:set_markup('<i>&lt;Invalid text&gt;</i>')
			end
		end
		bgb:set_bg(bg)
		if type(bg_image) == 'function' then
			-- TODO: Why does this pass nil as an argument?
			bg_image = bg_image(tb, o, nil, objects, i)
		end
		bgb:set_bgimage(bg_image)

		bgb.shape = args.shape
		bgb.shape_border_width = args.shape_border_width
		bgb.shape_border_color = args.shape_border_color

		w:add(bgb)
	end
end


local tasklist_menu = awful.menu({
	items = { },
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, beautiful.client_radius)
	end,
})


local tasklist_menu_background = wibox {
	ontop = true,
	screen = awful.screen.focused(),
	bg = beautiful.transparent,
	type = 'utility',
	x = 0,
	y = 0,
	width = dpi(6000), -- large values to cover both screens
	height = dpi(3000),
	visible = false
}

is_client_docked = function(c)
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
			if item["name"] == c.class then
				already_docked = true
			end
		end
	end
	file:close()
	return already_docked
end

get_docked_apps = function()
	file = io.open(os.getenv("HOME").."/.config/awesome/docked_apps.conf","r")
	if file then 
		local docked_apps = file:read("a*")
		if docked_apps == "" then
			docked_apps_table = {
				["apps"] = {}
			}
		else
			docked_apps_table = json.decode(docked_apps)
		end
		file:close()
		--print(docked_apps_table)
		return docked_apps_table
	else
		return {
			["apps"] = {}
		}
	end
end

delete_docked_client  = function(name)
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

append_docked_client = function(c)
	local already_docked = is_client_docked(c)
	file = io.open(os.getenv("HOME").."/.config/awesome/docked_apps.conf","w")
	if not already_docked then
		awful.spawn.easy_async("ps -p "..c.pid.." -o command", function(stdout, stderr, reason, exit_code)
			local s = gears.surface(c.icon)
			local img = cairo.ImageSurface.create(cairo.Format.ARGB32, s:get_width(), s:get_height())
			local cr  = cairo.Context(img)
			cr:set_source_surface(s, 0, 0)
			cr:paint()
			local icon_file_path = os.getenv("HOME").."/.config/awesome/docked_apps/"..c.class..".png"
			img:write_to_png(icon_file_path)
			--print(stdout)
			cmd = stdout:gsub("COMMAND","")
			cmd = cmd:gsub("\n","")
			--print(cmd)
			table.insert(docked_apps_table["apps"],{
				["name"] = c.class,
				["cmd"] = cmd,
				["icon"] = icon_file_path
			})
			file:write(json.encode(docked_apps_table))
			file:close()

			awesome.emit_signal("update::taskbar")

		end)
	end
end

tasklist_open = function (c, docked, docked_client)
	--screen = awful.screen.focused()
	
	-- clear previous menu
	tasklist_menu = awful.menu({
		items = { },
		auto_expand = true,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, beautiful.client_radius)
		end,
	})

	tasklist_menu_background.visible = true
	tasklist_menu_visible = true

	if docked then
		tasklist_menu:add({
			"Undock",
			function()
				delete_docked_client(c.name)
			end
		})
		if docked_client then
			tasklist_menu:add({
				"Close",
				function()
					docked_client:kill()
				end
			})
		end
	else
		tasklist_menu:add({
			"Close",
			function()
				c:kill()
			end
		})
		tasklist_menu:add({
			"Dock",
			function()
				append_docked_client(c)
			end
		})
	end
	tasklist_menu:show()
end

tasklist_close = function ()
	tasklist_menu:hide()
	tasklist_menu_visible = false
	tasklist_menu_background.visible = false
end

tasklist_menu_background:buttons(
	awful.util.table.join(
		awful.button(
			{},
			1,
			nil,
			function()
				tasklist_close()
			end
		),
		awful.button(
			{},
			3,
			nil,
			function()
				tasklist_close()
			end
		)
	)
)

local tasklist_menu_visible = false

local tasklist_buttons =
	awful.util.table.join(
	awful.button(
		{},
		1,
		function(c)
			if c == _G.client.focus then
				c.minimized = true
			else
				-- Without this, the following
				-- :isvisible() makes no sense
				c.minimized = false
				if not c:isvisible() and c.first_tag then
					c.first_tag:view_only()
				end
				-- This will also un-minimize
				-- the client, if needed
				_G.client.focus = c
				c:raise()
			end
		end
	),
	awful.button(
		{},
		2,
		function(c)
			c:kill()
		end
	),
	awful.button(
		{},
		3,
		function(c)
			if not tasklist_menu_visible then
				tasklist_open(c, false, false)
			else
				tasklist_close()
			end
		end
	),
	awful.button(
		{},
		4,
		function()
			awful.client.focus.byidx(1)
		end
	),
	awful.button(
		{},
		5,
		function()
			awful.client.focus.byidx(-1)
		end
	)
)

local docked_app_widget = function(s, docked_app)
	local background_role = wibox.container.background {
		forced_height = dpi(3),
	}

	local bg = wibox.widget
	{
		{
			{
				{
					image = docked_app["icon"],
					widget = wibox.widget.imagebox,
				},
				top = dpi(8),
				bottom = dpi(8),
				left = dpi(8),
				right = dpi(8),
				forced_height = dpi(48),
				widget = wibox.container.margin
			},
			background_role,
			widget = wibox.layout.align.vertical,
		},
		widget = wibox.container.background
	}

	bg:buttons(
		awful.util.table.join(
			awful.button(
				{},
				1,
				nil,
				function()
					awful.spawn(docked_app.cmd)
				end
			),
			awful.button(
				{},
				3,
				nil,
				function()
					if not tasklist_menu_visible then
						tasklist_open(docked_app, true, false)
					else
						tasklist_close()
					end
				end
			)
		)
	)

	local old_set_bg = background_role.set_bg
	background_role.set_bg = function(s, bg_color)
		if bg_color then
			bg.bg = bg_color .. '20'
		end
		return old_set_bg(s, bg_color)
	end

	old_bg = bg.bg

	bg:connect_signal("docked::app::quitting", function(w, c, screen)
		--print("DOCKED APP IS QUITTING, CHANGING BG COLOR")
		--print(inspect(c))
		bg.bg = beautiful.transparent
		bg:buttons(
			awful.util.table.join(
				awful.button(
					{},
					1,
					nil,
					function()
						awful.spawn(docked_app.cmd)
						background_role.bg = '#3a86ff'
						bg.bg = '#3a86ff20'
						old_bg = bg.bg
					end
				),
				awful.button(
					{},
					3,
					nil,
					function()
						if not tasklist_menu_visible then
							tasklist_open(docked_app, true, false)
						else
							tasklist_close()
						end
					end
				)
			)
		)
		bg:connect_signal('mouse::leave', function()
			bg.bg = beautiful.transparent
		end)
	end)

	bg:connect_signal("docked::app::gaining_focus", function(w, c, screen)
		background_role.bg = '#3a86ff'
		bg.bg = '#3a86ff20'
		old_bg = bg.bg
	end)

	bg:connect_signal("docked::app::losing_focus", function(w, c, screen)
		background_role.bg = beautiful.transparent
		bg.bg = beautiful.groups_bg
		old_bg = bg.bg
	end)

	bg:connect_signal("docked::app::running", function(w, c, screen)
		--print("DOCKED APP IS RUNNING, CHANGING BG COLOR")
		--print(inspect(c))
		bg.bg = beautiful.groups_bg
		bg:buttons(
			awful.util.table.join(
				awful.button(
					{},
					1,
					nil,
					function()
						if c then
							if _G.client.focus == c then
								c.minimized = true
								background_role.bg = '#aaaaaa'
								bg.bg = beautiful.groups_bg
								old_bg = bg.bg
							else
								c:jump_to(false)
								background_role.bg = '#3a86ff'
								bg.bg = '#3a86ff20'
								old_bg = bg.bg
								--_G.client.focus = c
								--c:raise()
							end
						end
					end
				),
				awful.button(
					{},
					3,
					nil,
					function()
						if not tasklist_menu_visible then
							tasklist_open(docked_app, true, c)
						else
							tasklist_close()
						end
					end
				)
			)
		)
		old_bg = bg.bg
		bg:connect_signal('mouse::leave', function()
			if _G.client.focus == c then
				bg.bg = '#3a86ff20'
			else
				bg.bg = beautiful.groups_bg
			end
		end)
	end)

	bg:connect_signal("mouse::enter", function()
		old_bg = bg.bg
		bg.bg = beautiful.groups_title_bg
	end)

	bg:connect_signal('mouse::leave', function()
		bg.bg = beautiful.transparent
	end)

	local task_tooltip = awful.tooltip {
		objects = {bg},
		text = docked_app.name,
		margins = dpi(8),
		mode = 'outside',
		align = 'top'
	}

	return  bg
end


local TaskList = function(s)
--	return awful.widget.tasklist {
--		screen = s,
--		filter = awful.widget.tasklist.filter.currenttags,
--		buttons = tasklist_buttons,
--		layout = {
--	              spacing = 5,
--                      layout  = wibox.layout.fixed.horizontal
--		},
--		update_function = list_update,
--		wibox.layout.fixed.horizontal()
--	       }

			local docked_apps_layout = wibox.layout.fixed.horizontal()
			docked_apps_layout.spacing = dpi(5)
			local docked_app_widgets = {}

			local da = get_docked_apps()
			for i=1, #da["apps"] do
				--print(da["apps"][i])
				--print(da["apps"][i]["name"])
				local widget = docked_app_widget(s, da["apps"][i])
				table.insert(docked_app_widgets, {name = da["apps"][i]["name"], widget = widget})
				if widget then
					docked_apps_layout:add(widget)
				end
			end

			local filter_tasklist = function(c, screen)
				local l = awful.widget.tasklist.filter.alltags(c, screen)
				if is_client_docked(c) then
					for i=1, #docked_app_widgets do
						if docked_app_widgets[i].name == c.class and c.screen == screen then
							docked_app_widgets[i].widget:emit_signal("docked::app::running", c, screen)
							c:connect_signal("request::unmanage", function()
								docked_app_widgets[i].widget:emit_signal("docked::app::quitting", c, screen)
							end)
							c:connect_signal("unfocus", function()
								docked_app_widgets[i].widget:emit_signal("docked::app::losing_focus", c, screen)
							end)
							c:connect_signal("focus", function()
								docked_app_widgets[i].widget:emit_signal("docked::app::gaining_focus", c, screen)
							end)
						end
					end
					return false
				end
				return l
			end

			return wibox.widget {
				docked_apps_layout,
				awful.widget.tasklist {
					screen   = s,
					filter   = filter_tasklist,
					buttons  = tasklist_buttons,
					layout   = {
							spacing = dpi(5),
							layout  = wibox.layout.fixed.horizontal
					},
					style = {
						bg_normal = 'transparent',
						bg_minimize = '#aaaaaa',
						bg_urgent = 'transparent',
						bg_focus = '#3a86ff'
					},
					widget_template = {
							{
								{
										{
												{
													id = 'clienticon',
													widget = awful.widget.clienticon,
												},
												top = dpi(8),
												bottom = dpi(8),
												left = dpi(8),
												right = dpi(8),
												forced_height = dpi(48),
												widget = wibox.container.margin
										},
										{
											wibox.widget.base.make_widget(),
											forced_height = dpi(3),
											id            = 'background_role',
											widget        = wibox.container.background,
										},
										widget = wibox.layout.align.vertical,
								},
								id = 'bg',
								bg = beautiful.groups_bg,
								widget = wibox.container.background
							},
							nil,
							create_callback = function(self, c, index, objects) --luacheck: no unused args
									self:get_children_by_id('clienticon')[1].client = c
									local icon_theme_icon_path = mutils.lookup_icon_uncached(c.class)
									if not icon_theme_icon_path then
										icon_theme_icon_path = mutils.lookup_icon_uncached(c.name)
										if not icon_theme_icon_path then
											icon_theme_icon_path = icons.default_app
										end
									end
									self:get_children_by_id('clienticon')[1].image = icon_theme_icon_path
									self:get_children_by_id('clienticon')[1]:emit_signal("widget::redraw_needed")

									local bgb = self:get_children_by_id('background_role')[1]
									local bg = self:get_children_by_id('bg')[1]
									local old_set_bg = bgb.set_bg
									bgb.set_bg = function(s, bg_color)
										if bg_color and not(bg_color == 'transparent') then
											bg.bg = bg_color .. '20'
											old_bg = bg.bg
										end
										if bg_color == 'transparent' then
											bg.bg = beautiful.groups_bg
											old_bg = bg.bg

										end
										if _G.client.focus == c then
											bg.bg = '#3a86ff20'
											old_bg = bg.bg
										end
										return old_set_bg(s, bg_color)
									end

									old_bg = bg.bg

									bg:connect_signal("mouse::enter", function()
										old_bg = bg.bg
										bg.bg = beautiful.groups_title_bg
									end)

									bg:connect_signal('mouse::leave', function()
										bg.bg = old_bg
									end)

									local task_tooltip = awful.tooltip {
										objects = {bg},
										text = c.class,
										margins = dpi(8),
										mode = 'outside',
										align = 'top'
									}
							end,
							layout = wibox.layout.align.vertical,
					},
				},
				nil,
				spacing = dpi(5),
				layout = wibox.layout.fixed.horizontal
			}
end

return TaskList
