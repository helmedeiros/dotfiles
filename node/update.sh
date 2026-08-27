#!/usr/bin/env bash
#
# node/update.sh
#
# Update the pinned Node runtime and the global npm packages.
#
# Extracted from bin/dot, where these 130-odd lines were more than half the
# script and buried what dot actually orchestrates. Running it as its own file
# also makes it invocable on its own — previously the only way to re-run an npm
# update was to run the whole of dot.
#
# Never fails the caller: bin/dot treats a Node problem as non-fatal, and that
# is preserved here by the trailing exit 0.

set -uo pipefail

ZSH="${ZSH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"
# Never auto-switch on cd: this script picks the version deliberately.
export NVM_AUTO_USE=false

# Source the existing NVM configuration
if [ -f "$ZSH/node/path.zsh" ]; then
	echo "Sourcing existing NVM configuration"
	source "$ZSH/node/path.zsh" || echo "Failed to source NVM configuration"

	# Check if NVM is actually installed. `command -v nvm` is not enough:
	# node/path.zsh always defines an nvm() stub function (even with no
	# ~/.nvm), so it reports true regardless of real install state.
	if [ -s "$NVM_DIR/nvm.sh" ] && command -v nvm &> /dev/null; then
		# The Node version is frozen deliberately, so every machine lands on
		# the same runtime instead of drifting with whatever --lts points at
		# today. node/.nvmrc is the single source of truth — node/install.sh
		# reads the same file. Bump it there, not here.
		#
		# It must stay new enough for npm@latest: the previous 20.19.0 pin
		# outlived Node 20's April 2026 EOL, and npm 12 refuses to install on
		# it (EBADENGINE), so every run silently failed to update npm.
		nodeVersion="$(cat "$ZSH/node/.nvmrc" 2>/dev/null || echo "--lts")"

		echo "Using NVM to install Node.js $nodeVersion"
		nvm install "$nodeVersion" || echo "Failed to install Node.js $nodeVersion"

		# Explicitly use this version (no auto-use)
		nvm use "$nodeVersion" || {
			echo "Failed to use Node.js $nodeVersion, falling back to LTS"
			nvm install --lts
			nvm use --lts || echo "Failed to use LTS version, continuing with system Node.js"
		}

		# Verify Node.js is available
		if command -v node &> /dev/null; then
			echo "Node.js version: $(node -v)"

			# Now update npm with the compatible Node.js version
			echo "› npm upgrade"
			npm install -g npm@latest --no-fund || echo "Failed to update npm"

			# Remove Angular CLI as it's no longer needed
			npm uninstall -g @angular/cli 2>/dev/null || true

			# Remove Claude Code from npm (now installed via Homebrew cask)
			npm uninstall -g @anthropic-ai/claude-code 2>/dev/null || true

			# Get list of outdated packages using the same logic as check-updates
			echo "› Checking for outdated global npm packages"

			# Create a temporary directory for our work
			TEMP_DIR=$(mktemp -d)

			# Get list of globally installed packages
			npm list -g --depth=0 --json > "$TEMP_DIR/installed.json" 2>/dev/null

			# Check if we got valid JSON
			if jq -e . "$TEMP_DIR/installed.json" >/dev/null 2>&1; then
				# Extract package names and versions
				jq -r '.dependencies | to_entries[] | "\(.key)@\(.value.version)"' "$TEMP_DIR/installed.json" > "$TEMP_DIR/installed_packages.txt"

				# Initialize outdated packages array
				OUTDATED_PACKAGES=()
				HAS_OUTDATED=false

				# Check each package individually
				while IFS= read -r package_info; do
					# Handle scoped packages correctly by finding the last @ symbol
					package_name=$(echo "$package_info" | sed 's/@\([^@]*\)$//' | sed 's/^@//')
					current_version=$(echo "$package_info" | sed 's/.*@\([^@]*\)$/\1/')

					# For scoped packages, add the @ back
					if [[ "$package_info" == @* ]]; then
						package_name="@$package_name"
					fi

					# Skip npm (handled separately) and corepack (bundled with Node.js)
					if [ "$package_name" = "npm" ] || [ "$package_name" = "corepack" ]; then
						continue
					fi

					# Try to get the latest version
					latest_version=$(npm view "$package_name" version 2>/dev/null)

					if [ -n "$latest_version" ] && [ "$current_version" != "$latest_version" ]; then
						OUTDATED_PACKAGES+=("$package_name")
						HAS_OUTDATED=true
					fi
				done < "$TEMP_DIR/installed_packages.txt"

				# Update outdated packages
				if [ "$HAS_OUTDATED" = true ]; then
					echo "› Installing latest versions of outdated global npm packages"
					echo "Packages to update: ${OUTDATED_PACKAGES[*]}"

					# Install latest version of each outdated package
					for package in "${OUTDATED_PACKAGES[@]}"; do
						echo "  Updating $package to latest version..."
						if npm install -g "$package@latest" --no-fund 2>&1; then
							echo "  ✅ Successfully updated $package"
						else
							echo "  ❌ Failed to update $package"
						fi
					done
				else
					echo "› All global npm packages are up to date"
				fi
			else
				echo "› Could not parse npm package information. Skipping npm updates."
			fi

			# Clean up
			rm -rf "$TEMP_DIR"

			# Run npm audit fix but don't show warnings about deprecated packages
			echo "› Running npm audit fix"
			npm audit fix --force --no-fund --silent || echo "npm audit fix had issues"
			echo "Node.js and npm update completed"
		else
			echo "Node.js is not available after NVM setup. Something went wrong."
		fi
	else
		echo "NVM not properly loaded. Running node/install.sh to set up NVM"
		"$ZSH/node/install.sh" || echo "Failed to run node/install.sh"
	fi
else
	echo "NVM configuration not found. Running node/install.sh to set up NVM"
	"$ZSH/node/install.sh" || echo "Failed to run node/install.sh"
fi

exit 0
