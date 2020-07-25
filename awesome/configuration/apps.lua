local filesystem = require('gears.filesystem')

local config_dir = filesystem.get_configuration_dir()
local bin_dir = config_dir .. 'binaries/'


return {

	-- The default applications in keybindings and widgets
	default = {
		terminal 												= 'alacritty',																								-- Terminal Emulator
		text_editor 										= 'vscode',																										-- GUI Text Editor
		web_browser 										= 'firefox-developer-edition',																-- Web browser
		file_manager 										= 'nautilus',																									-- GUI File manager
		network_manager 								= 'nm-connection-editor',																			-- Network manager
		bluetooth_manager								= 'blueman-manager',																					-- Bluetooth manager
		power_manager 									= 'xfce4-power-manager',																			-- Power manager
		package_manager 								= 'pamac-manager',																						-- GUI Package manager
		lock 														= 'awesome-client "_G.show_lockscreen()"',  									-- Lockscreen
		quake 													= 'kitty --name QuakeTerminal',
		rofiglobal											= 'rofi -dpi ' .. screen.primary.dpi ..
																	    ' -show "Global Search" -modi "Global Search":' .. config_dir ..
																	    '/configuration/rofi/sidebar/rofi-spotlight.sh' ..
																	    ' -theme ' .. config_dir ..
																	    '/configuration/rofi/sidebar/rofi.rasi', 											-- Rofi Web Search
		rofiappmenu 										= 'rofi -dpi ' .. screen.primary.dpi ..
																	    ' -show drun -theme ' .. config_dir ..
																	    '/configuration/rofi/appmenu/rofi.rasi'  											-- Application Menu

		-- You can add more default applications here
	},
	-- List of apps to start once on start-up

	run_on_start_up = {
		'picom -b --xrender-sync-fence --experimental-backends --dbus --config ' ..
		config_dir .. '/configuration/picom.conf',   																											-- Compositor
		'blueman-applet',																																									-- Bluetooth tray icon
		'/usr/lib/mate-polkit/polkit-mate-authentication-agent-1 &' ..
		' eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)',           								-- Credential manager
		'xrdb $HOME/.Xresources', 																																				-- Load X Colors
		'nm-applet',																																											-- NetworkManager Applet
		'pulseeffects --gapplication-service',																														-- Sound Equalizer
		--'xrandr --output DP-2 --primary --scale 1x1 --pos 2880x0 --panning 3840x2160+2880+0 --auto --output HDMI-0 --scale 1.5x1.5 --mode 1920x1080 --fb 6720x2160 --pos 0x0 --panning 2880x1620', -- configure display scaling
		'xidlehook --not-when-fullscreen --not-when-audio --timer 600 '..
		' "awesome-client \'_G.show_lockscreen()\'" ""',																									-- Auto lock timer
		'killall synology-drive ; synology-drive start',
		'killall polychromatic-tray-applet ; polychromatic-tray-applet',
		'killall drop ; drop',
		'killall flameshot ; flameshot'
		-- You can add more start-up applications here
	},

	-- List of binaries that will execute a certain task

	bins = {
		full_screenshot = bin_dir .. 'snap full',              					                    					-- Full Screenshot
		area_screenshot = bin_dir .. 'snap area',			                                        					-- Area Selected Screenshot
		update_profile  = bin_dir .. 'profile-image'
	}
}
