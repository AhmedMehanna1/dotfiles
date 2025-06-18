#!/bin/bash


mkdir -p ~/.tmux
ln -fvs ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -fvs ~/.dotfiles/tmux/tmux-status.conf ~/.tmux/tmux-status.conf

rm -rf ~/.tmux/plugins/tpm ~/.config/tinted-theming/base16-fzf

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/tinted-theming/base16-fzf.git ~/.config/tinted-theming/base16-fzf
