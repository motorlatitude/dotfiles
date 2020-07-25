local awful = require('awful')
local gears = require('gears')
local beautiful = require('beautiful')

local icons = require('theme.icons')

local tags = {
	{
		icon = icons.terminal,
		type = 'terminal',
		default_app = 'alacritty',
		text = 'General',
		screen = 1
	},
	{
		icon = icons.web_browser,
		type = 'chrome',
		default_app = 'firefox',
		text = 'Browser',
		screen = 1
	},
	{
		icon = icons.multimedia,
		type = 'music',
		default_app = 'vlc',
		text = 'Multimedia',
		screen = 1
	},
	{
		icon = icons.development,
		type = 'any',
		default_app = '',
		text = 'Development',
		screen = 1
	}
	-- {
	--   icon = icons.social,
	--   type = 'social',
	--   default_app = 'discord',
	--   screen = 1
	-- }
}


tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
			awful.layout.suit.floating,
			awful.layout.suit.spiral.dwindle,
			awful.layout.suit.tile,
			awful.layout.suit.max
    })
end)


screen.connect_signal("request::desktop_decoration", function(s)
	for i, tag in pairs(tags) do
		awful.tag.add(
			tag.text,
			{
				icon = tag.icon,
				icon_only = true,
				layout = awful.layout.suit.floating,
				gap_single_client = true,
				gap = beautiful.useless_gap,
				screen = s,
				default_app = tag.default_app,
				selected = i == 1
			}
		)
	end
end)