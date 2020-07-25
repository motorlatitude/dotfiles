local gears = require('gears')
local wibox = require('wibox')
local awful = require('awful')
local ruled = require('ruled')
local naughty = require('naughty')
local menubar = require("menubar")
local beautiful = require('beautiful')

local dpi = beautiful.xresources.apply_dpi

local clickable_container = require('widget.clickable-container')

-- Defaults
naughty.config.defaults.ontop = true
naughty.config.defaults.icon_size = dpi(32)
naughty.config.defaults.timeout = 5
naughty.config.defaults.title = 'System Notification'
naughty.config.defaults.margin = dpi(16)
naughty.config.defaults.margin_top = dpi(50)
naughty.config.defaults.border_width = 0
naughty.config.defaults.position = 'top_right'
naughty.config.defaults.shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, dpi(4)) end

-- Apply theme variables

naughty.config.padding = 8
naughty.config.spacing = 8
naughty.config.icon_dirs = {
	"/usr/share/icons/Tela",
	"/usr/share/icons/McMuse-yellow-dark/",
	"/usr/share/icons/Papirus/",
	"/usr/share/icons/la-capitaine-icon-theme/",
	"/usr/share/icons/gnome/",
	"/usr/share/icons/hicolor/",
	"/usr/share/pixmaps/"
}
naughty.config.icon_formats = { "svg", "png", "jpg", "gif" }


-- Presets / rules

ruled.notification.connect_signal('request::rules', function()
	
	-- Critical notifs
	ruled.notification.append_rule {
		rule       = { urgency = 'critical' },
		properties = { 
			font        		= 'SF Pro Text Bold 10',
			bg 					= '#ff0000', 
			fg 					= beautiful.fg_normal_dark,
			margin 				= dpi(16),
			position 			= function(c) 
				return awful.placement.top_right(c, {
					margins = {
						top = dpi(50)
					}
				})
			end,
			implicit_timeout	= 0
		}
	}

	-- Normal notifs
	ruled.notification.append_rule {
		rule       = { urgency = 'normal' },
		properties = {
			font        		= 'SF Pro Text Regular 10',
			bg      			= '#ffffff'.. '55', 
			fg 					= beautiful.fg_normal_dark,
			margin 				= dpi(16),
			position 			= function(c) 
				return awful.placement.top_right(c, {
					margins = {
						top = dpi(50)
					}
				})
			end,
			position 			= 'top_right',
			implicit_timeout 	= 5
		}
	}

	-- Low notifs
	ruled.notification.append_rule {
		rule       = { urgency = 'low' },
		properties = { 
			font        	= 'SF Pro Text Regular 10',
			bg     				= '#ffffff'.. '55',
			fg 						= beautiful.fg_normal_dark,
			margin 				= dpi(16),
			position 			= function(c) 
				return awful.placement.top_right(c, {
					margins = {
						top = dpi(50)
					}
				})
			end,
			position 			= 'top_right',
			implicit_timeout	= 5
		}
	}
end)


-- Error handling
naughty.connect_signal(
	"request::display_error",
	function(message, startup)
	    naughty.notification {
	        urgency = "critical",
	        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
	        message = message,
	        app_name = 'System Notification',
	        icon = beautiful.awesome_icon
	    }
	end
)

-- XDG icon lookup
naughty.connect_signal(
	"request::icon",
	function(n, context, hints)
	    if context ~= "app_icon" then return end

	    local path = menubar.utils.lookup_icon(hints.app_icon) or
	        menubar.utils.lookup_icon(hints.app_icon:lower())

	    if path then
	        n.icon = path
	    end
	end
)

-- Naughty template
naughty.connect_signal("request::display", function(n)

	-- naughty.actions template
	local actions_template = wibox.widget {
		notification = n,
		base_layout = wibox.widget {
			spacing        = dpi(0),
			layout         = wibox.layout.flex.horizontal
		},
		widget_template = {
			{
				{
					{
						{
							id     = 'text_role',
							font   = 'SF Pro Text Regular 10',
							widget = wibox.widget.textbox
						},
						widget = wibox.container.place
					},
					widget = clickable_container
				},
				bg                 = '#ffffff'.. '55',
				shape              = gears.shape.rounded_rect,
				forced_height      = dpi(30),
				widget             = wibox.container.background
			},
			margins = dpi(4),
			widget  = wibox.container.margin
		},
		style = { underline_normal = false, underline_selected = true },
		widget = naughty.list.actions
	}

	local top_margin = dpi(50)
	if #naughty.active > 1 then
		top_margin = dpi(15)
	end

	local has_icon = false
	if n.icon then
		has_icon = true
	end

	-- Custom notification layout
	naughty.layout.box {
		notification = n,
		type = "notification",
		screen = awful.screen.preferred(),
		shape = gears.shape.rectangle,
		widget_template = {
			{
				{
					{
						{
							{
								{
									{
										{
											nil,
											{
												{
													{
														{
															resize_strategy = 'scale',
															widget = naughty.widget.icon,
															forced_width = dpi(64),
															forced_height = dpi(64),
															opacity = 1,
														},
														shape = function(cr, w, h) 
															gears.shape.rounded_rect(cr, w, h, dpi(4))
														end,
														forced_width = dpi(55),
														forced_height = dpi(55),
														widget = wibox.container.background
													},
													visible = has_icon,
													margins = dpi(10),
													widget  = wibox.container.margin,
												},
												{
													{
														layout = wibox.layout.align.vertical,
														expand = 'none',
														nil,
														{
															{
																markup = '<span color="#333333de">' .. (n.app_name or 'System Notification') .. '</span>',
																font = 'IBM Plex Sans Bold 13',
																align = 'left',
																valign = 'center',
																fg = beautiful.fg_normal_dark,
																widget = wibox.widget.textbox
															},
															{
																align = 'left',
																font = 'IBM Plex Sans Medium 11',
																markup = '<span color="#333333de">' .. (n.title or 'System Notification') .. '</span>',
																widget = wibox.widget.textbox
															},
															{
																align = "left",
																font = 'IBM Plex Sans 10',
																widget = naughty.widget.message,
															},
															layout = wibox.layout.fixed.vertical
														},
														nil
													},
													top = dpi(5),
													bottom = dpi(5),
													right = dpi(5),
													left = dpi(10),
													widget  = wibox.container.margin,
												},
												layout = wibox.layout.fixed.horizontal,
											},
											spacing = beautiful.notification_margin,
											layout  = wibox.layout.fixed.vertical,
										},
										-- Margin between the fake background
										-- Set to 0 to preserve the 'titlebar' effect
										margins = dpi(0),
										widget  = wibox.container.margin,
									},
									bg = beautiful.transparent,
									widget  = wibox.container.background,
								},
								-- Notification action list
								-- naughty.list.actions,
								actions_template,
								spacing = dpi(4),
								layout  = wibox.layout.fixed.vertical,
							},
							bg     = beautiful.transparent,
							id     = "background_role",
							widget = naughty.container.background,
						},
						strategy = "min",
						width    = dpi(350),
						widget   = wibox.container.constraint,
					},
					strategy = "max",
					width    = beautiful.notification_max_width or dpi(350),
					height = dpi(200),
					widget   = wibox.container.constraint,
				},
				-- Anti-aliasing container
				-- Real BG
				bg = '#ffffff'..'ee',
				-- This will be the anti-aliased shape of the notification
				shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, dpi(6)) end,
				widget = wibox.container.background
			},
			-- Margin of the fake BG to have a space between notification and the screen edge
			--margins = dpi(15),--beautiful.notification_margin,
			top = top_margin,
			right = dpi(10),
			widget  = wibox.container.margin
		}
	
	}

	-- Destroy popups if dont_disturb mode is on
	-- Or if the floating_panel is visible
	local focused = awful.screen.focused()
	if _G.dont_disturb or (focused.floating_panel and focused.floating_panel.visible) then
		naughty.destroy_all_notifications(nil, 1)
	end

end)
