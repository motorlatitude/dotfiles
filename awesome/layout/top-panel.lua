local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')

local icons = require('theme.icons')
local dpi = beautiful.xresources.apply_dpi

local clickable_container = require('widget.clickable-container')
local task_list = require('widget.task-list')

local TopPanel = function(s)

	local panel = wibox
	{
		ontop = true,
		screen = s,
		type = 'dock',
		width = s.geometry.width,
		x = s.geometry.x,
		y = s.geometry.height - dpi(50),
		ontop = true,
		visible = true,
		height = dpi(50),
		maximum_height = dpi(50),
		stretch = false,
		bg = beautiful.background,
		fg = beautiful.fg_normal
	}

	panel:connect_signal(
		'mouse::enter',
		function() 
			local w = mouse.current_wibox
			if w then
				w.cursor = 'left_ptr'
			end
		end

	)


	s.add_button = wibox.widget {
		{
			{
				{
					{
						image = icons.plus,
						resize = true,
						widget = wibox.widget.imagebox
					},
					margins = dpi(4),
					widget = wibox.container.margin
				},
				widget = clickable_container
			},
			bg = beautiful.transparent,
			shape = gears.shape.circle,
			widget = wibox.container.background
		},
		margins = dpi(4),
		widget = wibox.container.margin
	}

	s.add_button:buttons(
		gears.table.join(
			awful.button(
				{},
				1,
				nil,
				function()
					awful.spawn(
						awful.screen.focused().selected_tag.default_app,
						{
							tag = mouse.screen.selected_tag,
							placement = awful.placement.bottom_right
						}
					)
				end
			)
		)
	)

	local layout_box = function(s)
		local layoutbox = wibox.widget {
			{
				awful.widget.layoutbox(s),
				margins = dpi(7),
				widget = wibox.container.margin
			},
			widget = clickable_container
		}
		layoutbox:buttons(
			awful.util.table.join(
				awful.button(
					{},
					1,
					function()
						awful.layout.inc(1)
					end
				),
				awful.button(
					{},
					3,
					function()
						awful.layout.inc(-1)
					end
				),
				awful.button(
					{},
					4,
					function()
						awful.layout.inc(1)
					end
				),
				awful.button(
					{},
					5,
					function()
						awful.layout.inc(-1)
					end
				)
			)
		)
		return layoutbox
	end

	local build_widget = function(widget)
		return wibox.widget {
			{
				widget,
				bg = beautiful.groups_title_bg,
				shape = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, dpi(6))
				end,
				widget = wibox.container.background
			},
			top = dpi(10),
			bottom = dpi(10),
			widget = wibox.container.margin
		}
	end
	
	s.systray = wibox.widget {
		{
			base_size = dpi(18),
			horizontal = true,
			screen = 'primary',
			widget = wibox.widget.systray
		},
		visible = true,
		top = dpi(15),
		widget = wibox.container.margin
	}

	local separator =  wibox.widget {
		orientation = 'vertical',
		forced_height = dpi(1),
		forced_width = dpi(1),
		span_ratio = 0.55,
		widget = wibox.widget.separator
	}

	s.tray_toggler  = build_widget(require('widget.tray-toggler'))
	s.bluetooth     = build_widget(require('widget.bluetooth')())
	s.network       = build_widget(require('widget.network')())
	s.updater 			= build_widget(require('widget.package-updater')())
	s.search      	= require('widget.search-apps')()

	-- s.updater 	= require('widget.package-updater')()
	-- s.screen_rec 	= require('widget.screen-recorder')()
	-- s.music       	= require('widget.music')()
	-- s.globalsearch  = require('widget.globalsearch')()
	-- s.end_session	= require('widget.end-session')()
	s.float_panel  	= require('layout.floating-panel.floating-panel-opener')()
	s.appmenu  	= require('layout.app-menu.app-menu-opener')()

	panel : setup {
		layout = wibox.layout.align.horizontal,
		expand = "inside",
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(5),
			--s.search,
			s.appmenu,
			task_list(s)
		},
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(5),
		},
		-- s.clock_widget,
		{
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(8),
				s.systray,
				s.tray_toggler,
				s.updater,
				s.bluetooth,
				s.network,
				build_widget(layout_box(s)),
				separator,
				s.float_panel,
			},
			right = dpi(12),
			layout = wibox.container.margin,
		}
	}
	return panel
end


return TopPanel
