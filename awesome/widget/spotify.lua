-------------------------------------------------
-- Spotify Widget for Awesome Window Manager
-- Shows currently playing song on Spotify for Linux client
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/spotify-widget

-- @author Pavel Makhov
-- @copyright 2018 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local dpi = require('beautiful').xresources.apply_dpi

local icons = require("theme.icons")

local GET_SPOTIFY_STATUS_CMD = 'sp status'
local GET_CURRENT_SONG_CMD = 'sp current-oneline'

local spotify_widget = {}

local function worker(args)

    local args = args or {}

    local play_icon = args.play_icon or icons.pause
    local pause_icon = args.pause_icon or icons.play
    local font = args.font or 'Play 9'

    spotify_widget = wibox.widget {
        {
            {
                id = "icon",
                resize = true,
                widget = wibox.widget.imagebox,
            },
            margins = dpi(10),
            widget = wibox.container.margin
        },
        {
            {
                {
                    id = 'current_song',
                    widget = wibox.widget.textbox,
                    forced_height = dpi(28),
                    valign = 'center',
                    font = font
                },
                fg = '#9381ff',
                widget = wibox.container.background
            },
            top = dpi(3),
            bottom = dpi(2),
            left = dpi(3),
            right = dpi(10),
            forced_height = dpi(32),
            widget = wibox.container.margin
        },
        layout = wibox.layout.align.horizontal,
        set_status = function(self, is_playing)
            self:get_children_by_id('icon')[1].image = (is_playing and play_icon or pause_icon)
        end,
        set_text = function(self, path)
            self:get_children_by_id('current_song')[1].markup = path
        end,
    }

    local update_widget_icon = function(widget, stdout, _, _, _)
        stdout = string.gsub(stdout, "\n", "")
        widget:set_status(stdout == 'Playing' and true or false)
    end

    local update_widget_text = function(widget, stdout, _, _, _)
        local escaped = string.gsub(stdout, "&", '&amp;')
        escaped = string.gsub(escaped, "^ | ", '')
        if string.find(stdout, 'Error: Spotify is not running.') ~= nil then
            widget:set_text('')
            spotify_widget:set_visible(false)
        else
            widget:set_text(escaped)
            spotify_widget:set_visible(true)
        end
    end

    watch(GET_SPOTIFY_STATUS_CMD, 5, update_widget_icon, spotify_widget)
    watch(GET_CURRENT_SONG_CMD, 5, update_widget_text, spotify_widget)

    --- Adds mouse controls to the widget:
    --  - left click - play/pause
    --  - scroll up - play next song
    --  - scroll down - play previous song
    spotify_widget:connect_signal("button::press", function(_, _, _, button)
        if (button == 1) then
            awful.spawn("sp play", false)      -- left click
        elseif (button == 4) then
            awful.spawn("sp next", false)  -- scroll up
        elseif (button == 5) then
            awful.spawn("sp prev", false)  -- scroll down
        end
        awful.spawn.easy_async(GET_SPOTIFY_STATUS_CMD, function(stdout, stderr, exitreason, exitcode)
            update_widget_icon(spotify_widget, stdout, stderr, exitreason, exitcode)
        end)
    end)

    return spotify_widget

end

return setmetatable(spotify_widget, { __call = function(_, ...)
    return worker(...)
end })

