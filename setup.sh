sudo apt update
sudo apt upgrade

# copy-paste configuration
sudo apt install xclip
echo alias "c=xclip -selection clipboard" >> ~/.bash_aliases
echo alias "v=xclip -o" >> ~/.bash_aliases

# Kitty terminal emulator
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
sudo unzip JetBrainsMono.zip -d /usr/share/fonts
fc-cache -f -v

sudo apt install kitty

# Install Catppuccin Theme globally

# TODO: provide a conf file in this repo
cp /usr/share/doc/kitty/examples/kitty.conf ~/.config/kitty/
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
sudo update-alternatives --config x-terminal-emulator

# TODO: provide a theme conf in this repo
git clone https://github.com/dexpota/kitty-themes.git ~/.config/kitty/themes --depth 1
rm ~/.config/kitty/theme.conf && ln -s ~/.config/kitty/themes/ayu_mirage.conf ~/.config/kitty/theme.conf

# Neovim configuration
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
sudo mv nvim.appimage /usr/bin/nvim
echo "alias vim=nvim" >> ~/.bash_aliases

git clone https://github.com:nvchad/nvchad ~/.config/nvim --depth 1

# SmartCard daemon - used as an interface between OpenPGP and hardware keys
sudo apt install scdaemon

# Window environment
sudo apt install git

# Password manager
sudo apt install keepassxc

# Note taking application
sudo apt install xournalpp

# E-reader application
sudo apt install foliate

# Docker CLI
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enables touch scrolling in Firefox
sudo echo "MOZ_USE_XINPUT2 DEFAULT=1" >> /etc/security/pam_env.conf

# Applies styles to Firefox
git clone https://github.com/oliverabdulrahim/clean-firefox.git
cd clean-firefox
sh clean-firefox/install.sh
cd -

# Bash settings
echo 'export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)' >> ~/.bashrc
echo 'gpgconf --launch gpg-agent' >> ~/.bashrc
echo 'gpg-connect-agent /bye' >> ~/.bashrc
echo 'export GPG_TTY=$(tty)' ~/.bashrc

# Bash aliases configuration
echo "alias idea = nohup /opt/idea-IU-*/bin/idea.sh >/dev/null 2>&1 &" >> ~/.bash_aliases
echo "alias ll='ls -alF'" >> ~/.bash_aliases

# Git configuration
read -rp "Enter the GPG signing key id=" signing_key_id
read -rp "Enter the user.name to use for git=" git_user_name
read -rp "Enter the user.email to use for git=" git_user_email
git config --global commit.gpgsign true
git config --global tag.gpgSign true
git config --global user.signingKey $signing_key_id
git config --global init.defaultBranch main
git config --global user.email $git_user_email
git config --global user.name $git_user_name

# GPG configuration
echo "To trust keys stored in your YubiKey(s), you'll need to run gpg --edit-key "$git_user_email", then trust"

# YubiKey as sudo configuration
sudo apt-get install libpam-u2f
mkdir -p ~/.config/Yubico
pamu2fcfg > ~/.config/Yubico/u2f_keys
sudo cat << EOF
#%PAM-1.0

# Set up user limits from /etc/security/limits.conf.
session    required   pam_limits.so

session    required   pam_env.so readenv=1 user_readenv=0
session    required   pam_env.so readenv=1 envfile=/etc/default/locale user_readenv=0
auth sufficient pam_u2f.so cue [cue_prompt='Tap to authenticate as sudo...']
@include common-auth
@include common-account
@include common-session-noninteractive
EOF >/etc/pam.d/sudo
