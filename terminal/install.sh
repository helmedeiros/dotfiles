#!/bin/sh
##################################################################
# Terminal                                                       #
#################################################################

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)


# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Check if the theme is already installed
THEME_NAME="Solarized Dark xterm-256color"
THEME_INSTALLED=$(defaults read com.apple.Terminal "Window Settings" | grep -c "$THEME_NAME" || echo "0")

# Only install the theme if it's not already installed
if [ "$THEME_INSTALLED" -eq 0 ]; then
  echo "Installing terminal theme: $THEME_NAME"
  
  # Use a modified version of the Solarized Dark theme by default in Terminal.app
  osascript <<EOD
tell application "Terminal"
	local allOpenedWindows
	local initialOpenedWindows
	local windowID
	set themeName to "$THEME_NAME"
	(* Store the IDs of all the open terminal windows. *)
	set initialOpenedWindows to id of every window
	(* Open the custom theme so that it gets added to the list
	   of available terminal themes (note: this will open two
	   additional terminal windows). *)
	do shell script "open '$DOTFILES_ROOT/terminal/" & themeName & ".terminal'"
	(* Wait a little bit to ensure that the custom theme is added. *)
	delay 1
	(* Set the custom theme as the default terminal theme. *)
	set default settings to settings set themeName
	(* Get the IDs of all the currently opened terminal windows. *)
	set allOpenedWindows to id of every window
	repeat with windowID in allOpenedWindows
		(* Close the additional windows that were opened in order
		   to add the custom theme to the list of terminal themes. *)
		if initialOpenedWindows does not contain windowID then
			close (every window whose id is windowID)
		(* Change the theme for the initial opened terminal windows
		   to remove the need to close them in order for the custom
		   theme to be applied. *)
		else
			set current settings of tabs of (every window whose id is windowID) to settings set themeName
		end if
	end repeat
end tell
EOD
else
  echo "Terminal theme '$THEME_NAME' is already installed. Skipping."
  
  # Just set the theme as default without opening new windows
  osascript <<EOD
tell application "Terminal"
	set themeName to "$THEME_NAME"
	(* Set the custom theme as the default terminal theme. *)
	set default settings to settings set themeName
	(* Apply theme to current windows *)
	set current settings of tabs of every window to settings set themeName
end tell
EOD
fi

# Enable "focus follows mouse" for Terminal.app and all X11 apps
# i.e. hover over a window and start typing in it without clicking first
#defaults write com.apple.terminal FocusFollowsMouse -bool true
#defaults write org.x.X11 wm_ffm -bool true

# Enable Secure Keyboard Entry in terminal.app
# See: http://security.stackexchange.com/q/47749
defaults write com.apple.terminal SecureKeyboardEntry -bool true
