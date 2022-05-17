#!/usr/bin/env bash

git pull origin main;

function doIt() {
	if [ ! -x "$(command -v brew)" ]; then
		echo "Homebrew cannot be found, get it installed first"
		if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
			echo "Homebrew cannot be installed"
			exit 1
		fi
	fi

	echo "Fetch all deps from Brewfile"
	if ! brew bundle install; then
		echo "Something went wrong in installing deps from Brewfile"
	fi

	if [ -x "$(command -v zsh)" ]; then
		echo "We have zsh installed, and the following add-ons will be settled as well: on-my-zsh & powerlevel10k-theme"
		# oh-my-zsh
		if [ -x "$(command -v curl)" ]; then
			sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	  elif [ -x "$(command -v wget)" ]; then
			sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
		else
			echo "Neither curl nor wget is available for fetching the source of oh-my-zsh"
		fi

		# Powerlevel10k
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
	fi

	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude ".macos" \
		--exclude "bootstrap.sh" \
		--exclude "Brewfile" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . ~;
	source ~/.zshrc
	source ~/.bash_profile;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;
