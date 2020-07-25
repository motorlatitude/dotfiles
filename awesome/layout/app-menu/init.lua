local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local icons = require('theme.icons')
local scroll_widget = require('layout.app-menu.scroll-widget')

local dpi = beautiful.xresources.apply_dpi

local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'configuration/user-profile/'
local apps = require('configuration.apps')


local app_menu_sidebar = require('layout.app-menu.components.app-menu-sidebar')
local app_menu_app_list = require('layout.app-menu.components.app-menu-app-list')
local app_menu_profile_bg = require('layout.app-menu.components.app-menu-profile-bg')
local app_menu_profile = require('layout.app-menu.components.app-menu-profile')
local app_menu_shortcuts = require('layout.app-menu.components.app-menu-shortcuts')
local app_menu_context_menu = require('layout.app-menu.components.app-menu-context-menu')

local input_app_search = nil
local input_app_search_highlighted = false

local app_menu_panel = function(s)

	-- Set right panel geometry
	local menu_panel_height = dpi(700)
	local menu_panel_column = dpi(350)
	local menu_panel_margins = dpi(3)
	s.menu_panel = nil
	s.menu_panel_visible = false

	s.app_menu_sidebar_panel = app_menu_sidebar(s, menu_panel_height, menu_panel_margins)

	local separator = wibox.widget {
		orientation = 'horizontal',
		opacity = 0.0,
		forced_height = 15,
		widget = wibox.widget.separator,
	}

	s.search_text_widget = wibox.widget {
		markup = '<span font="SF Pro Text 10" foreground="#777777">Search Apps</span>',
		widget = wibox.widget.textbox
	}

	local sw = nil

	s.close_menu_panel = function()
		gears.debug.print_warning("Closing App Launcher Menu")
		s.menu_panel_visible = false

		s.app_menu_panel.visible = false
		for sc in screen do
			if sc.app_menu_backdrop_rdb then
				sc.app_menu_backdrop_rdb.visible = false
			end
		end
		s.app_menu_sidebar_panel:hide()
		s.app_menu_app_list:hide()
		s.app_menu_profile_bg:hide()
		s.app_menu_profile:hide()
		s.app_menu_shortcuts:hide()

		if s.app_menu_context_menu then
			s.app_menu_context_menu:hide()
		end

		input_app_search = nil
		s.password_grabber:stop()

		s.menu_panel.opened = false
		s.menu_panel:emit_signal('closed')
		-- Not needed anymore since watching pacman ideally
		--if sw then
		--	sw:update_applications()
		--end
	end

	s.app_menu_context_menu = app_menu_context_menu(s)

	sw = scroll_widget(s, menu_panel_column, s.close_menu_panel, s.app_menu_context_menu)

	s.app_menu_app_list = app_menu_app_list(s, sw, menu_panel_column, menu_panel_margins)
	s.app_menu_profile_bg = app_menu_profile_bg(s, menu_panel_column, menu_panel_margins)
	s.app_menu_profile = app_menu_profile(s, menu_panel_column, menu_panel_margins)
	s.app_menu_shortcuts = app_menu_shortcuts(s, menu_panel_column, menu_panel_margins)

	s.open_menu_panel = function()
		gears.debug.print_warning("Opening App Launcher Menu")

		awful.placement.top_left(s.menu_panel, {margins = {
			left = panel_margins,
			top = s.geometry.y + s.geometry.height - menu_panel_height - dpi(50)
			}, parent = s
		})

		s.menu_panel_visible = true

		for sc in screen do
			if sc.app_menu_backdrop_rdb then
				sc.app_menu_backdrop_rdb.visible = true
			end
		end
		s.app_menu_panel.visible = true
		s.app_menu_sidebar_panel:show()
		s.app_menu_app_list:show()
		s.app_menu_profile_bg:show()
		s.app_menu_profile:show()
		s.app_menu_shortcuts:show()

		input_app_search = nil
		s.search_text_widget:set_markup('<span font="SF Pro Text 10" foreground="#777777">Search Apps</span>')
		s.password_grabber:start()

		s.menu_panel.opened = true
		s.menu_panel:emit_signal('opened')
		sw:filter(input_app_search)
	end

	s.password_grabber = awful.keygrabber {
		auto_start          = true,
		stop_event          = 'release',
		mask_event_callback = true,
		keybindings = {
				awful.key {
						modifiers = {'Control'},
						key       = 'u',
						on_press  = function() 
							input_app_search = nil
							s.search_text_widget:set_markup('<span font="SF Pro Text 10" foreground="#777777">Search Apps</span>')
						end
				},
				awful.key {
					modifiers = {'Control'},
					key       = 'a',
					on_press  = function()
						if input_app_search ~= nil then
							s.search_text_widget:set_markup('<span font="SF Pro Text 10" foreground="#ffffff" background="#0066aa">' .. input_app_search .. '</span>')
							input_app_search_highlighted = true
						end
					end
				},
				awful.key {
						modifiers = {'Mod1', 'Mod4', 'Shift', 'Control'},
						key       = 'Return',
						on_press  = function(self)
							self:stop()
					end
				}
		},
		keypressed_callback = function(self, mod, key, command) 

			print(key)
			-- Clear input string
			if key == 'Escape' then
				-- Clear input threshold
				input_app_search = nil
				s.menu_panel.opened = false
				sw:filter(input_app_search)
				s.close_menu_panel()
				return
			end

			if key == 'BackSpace' and input_app_search_highlighted then
				input_app_search = nil
				input_app_search_highlighted = false
				sw:filter(input_app_search)
			elseif key == 'BackSpace' and input_app_search ~= nil then
				input_app_search = input_app_search:sub(1, #input_app_search - 1)
				sw:filter(input_app_search)
				if input_app_search == '' then
					input_app_search = nil
					sw:filter(input_app_search)
				end
			end

			if key == 'Down' then
				sw:move_select_down()
			end

			if key == 'Up' then
				sw:move_select_up()
			end

			if key == 'F5' then
				sw:update_applications()
			end

			-- Accept only the single charactered key
			-- Ignore 'Shift', 'Control', 'Return', 'F1', 'F2', etc., etc.
			if #key == 1 then

				if input_app_search == nil then
					input_app_search = key
				elseif input_app_search_highlighted then
					input_app_search_highlighted = false
					input_app_search = key
				else
					input_app_search = input_app_search .. key
					sw:filter(input_app_search)
				end
			end
			if input_app_search == nil then
				s.search_text_widget:set_markup('<span font="SF Pro Text 10" foreground="#777777">Search Apps</span>')
			else
				s.search_text_widget:set_markup('<span font="SF Pro Text 10">' .. input_app_search .. '</span>')
			end

		end,
		keyreleased_callback = function(self, mod, key, command)

			-- Validation
			if key == 'Return' then
				sw:spawn_on_enter()
				input_app_search = nil
				sw:filter(input_app_search)
			end

			if input_app_search == nil then
				s.search_text_widget:set_markup('<span font="SF Pro Text 10" foreground="#777777">Search Apps</span>')
			else
				s.search_text_widget:set_markup('<span font="SF Pro Text 10">' .. input_app_search .. '</span>')
			end
		end
	}

	s.menu_panel = awful.popup {
		widget = {
			{
				{
					{
						-- left sidebar with power and settings options
						{
							widget = wibox.container.margin,
							top = dpi(60),
							forced_width = dpi(60)
						},
						-- central app list
						{
							{
								expand = 'inside',
								layout = wibox.layout.align.vertical,
								spacing = dpi(3),
								nil,
								nil,
								{
									{
										{
											{
												{
													widget = wibox.widget.imagebox,
													image = icons.search,
													resize = true,
													forced_width = dpi(20),
													forced_height = dpi(20),
													opacity = 0.3
												},
												widget = wibox.container.margin,
												margins = dpi(15)
											},
											{
												s.search_text_widget,
												top = dpi(3),
												bottom = dpi(3),
												left = dpi(8),
												right = dpi(8),
												widget = wibox.container.margin
											},
											nil,
											layout = wibox.layout.fixed.horizontal,
											spacing = dpi(0)
										},
										bg = '#111111fa',
										shape = function(cr, w, h)
											gears.shape.rounded_rect(cr, w, h, dpi(3))
										end,
										forced_width = dpi(280),
										forced_height = dpi(50),
										widget = wibox.container.background
									},
									widget = wibox.container.margin,
									top = dpi(3)
								}
							},
							widget = wibox.container.margin,
							left = dpi(3),
							top = dpi(60)
						},
						-- right side widgets
						{
							{
								-- user profile information
								nil,
								-- shortcuts or pinned to starts?
								{
									{
										bg = '#11111100',
										shape = function(cr, w, h)
											gears.shape.rounded_rect(cr, w, h, dpi(5))
										end,
										forced_width = menu_panel_column,
										forced_height = dpi(30),
										widget = wibox.container.background
									},
									widget = wibox.container.margin,
									margins = dpi(0),
									forced_height = dpi(180),
									forced_width = dpi(420)
								},
								nil,
								layout = wibox.layout.fixed.vertical,
								spacing = dpi(3)
							},
							widget = wibox.container.margin,
							left = dpi(3),
						},
						layout = wibox.layout.fixed.horizontal,
					},
					margins = dpi(3),
					widget = wibox.container.margin
				},
				bg = beautiful.transparent,
				shape = function(cr, w, h)
					gears.shape.partially_rounded_rect(cr, w, h, false, true, false, false, beautiful.groups_radius)
				end,
				widget = wibox.container.background
			},
			widget = wibox.container.margin
		},
		screen = s,
		type = 'utility',
		visible = false,
		ontop = true,
		maximum_height = menu_panel_height,
		minimum_height = menu_panel_height,
		minimum_width = dpi(400*2 + 100),
		height = s.geometry.height,
		bg = beautiful.transparent,
		fg = beautiful.fg_normal,
		shape = gears.shape.rectangle
	}

	awful.placement.top_left(s.menu_panel, {margins = {
		left = panel_margins,
		top = s.geometry.y + s.geometry.height - menu_panel_height - dpi(50)
		}, parent = s
	})

	s.menu_panel.opened = false
	s.menu_panel.mode = "today_mode"

	s.app_menu_backdrop_rdb = wibox
	{
		ontop = false,
		screen = s,
		bg = beautiful.transparent,
		type = 'desktop',
		x = s.geometry.x,
		y = s.geometry.y,
		width = dpi(s.geometry.width),
		height = dpi(s.geometry.height),
	}

	-- Hide this panel when app dashboard is called.
	function s.menu_panel:HideDashboard()
		if s.menu_panel.opened then
			s.menu_panel.opened = false
			s.close_menu_panel()
		end
	end

	function s.menu_panel:toggle()
		s.menu_panel.opened  = not s.menu_panel.opened 
		if s.menu_panel.opened then
			s.open_menu_panel()
		else
			s.close_menu_panel()
		end
	end

	s.app_menu_backdrop_rdb:buttons(
		awful.util.table.join(
			awful.button(
				{},
				1,
				nil,
				function()
					for sc in screen do
						if sc.menu_panel then
							sc.menu_panel:HideDashboard()
						end
					end
				end
			)
		)
	)

	return s.menu_panel
end


return app_menu_panel


