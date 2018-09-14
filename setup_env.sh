
###############################################
# Install usefull pkgs
###############################################
sudo apt-get -y update

sudo apt-get -y install exfat-fuse exfat-utils
sudo apt-get -y install vim
sudo apt-get -y install git
sudo apt-get -y install gitg
sudo apt-get -y install gitk
sudo apt-get -y install ssh  # (meta package with openssh-client & openssh-server)
sudo apt-get -y install ipv6calc
sudo apt-get -y install minicom  # Usefull to access Danube via Serial
sudo apt-get -y install sshpass  # Useful to tunel scp

# sudo add-apt-repository ppa:ubuntu-toolchain-r/test

###############################################
# Install Sublime Text
###############################################
## run command to install the key:
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -

## add the apt repository via command:
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

## check updates and install sublime-text
sudo apt-get -y update
sudo apt-get -y install sublime-text

cat << EOF > ~/Desktop/Sublime.config
=================================
Package to install:
=================================
    "A File Icon",
    "Agila Theme",
    "ayu",
    "Boxy Theme",
    "BracketHighlighter",
    "CakePHP (Native)",
    "CakePHP (tmbundle)",
    "Color Highlighter",
    "Emmet",
    "GitGutter",
    "Materialize",
    "Package Control",
    "Seti_UI",
    "Seti_UX

=================================
In preference/settings:
=================================
{
    "always_show_minimap_viewport": true,
    "bold_folder_labels": true,
    "color_scheme": "Packages/ayu/ayu-dark.tmTheme",
    "draw_minimap_border": true,
    "ensure_newline_at_eof_on_save": true,
    "font_size": 9,
    "highlight_line": true,
    "ignored_packages":
    [
        "Vintage"
    ],
    "match_brackets": true,
    "match_brackets_angle": true,
    "match_brackets_braces": true,
    "match_brackets_content": true,
    "match_brackets_square": true,
    "match_tags": true,
    "shift_tab_unindent": true,
    "theme": "ayu-dark.sublime-theme",
    "translate_tabs_to_spaces": true,
    "trim_trailing_white_space_on_save": true,
    "ui_big_tabs": true,
    "ui_fix_tab_labels": true,
    "ui_font_default": true,
    "ui_font_size_small": false,
    "ui_font_source_code_pro": true,
    "ui_native_titlebar": true,
    "ui_separator": true,
    "ui_wide_scrollbars": true
}

=================================
In preference/Syntax specific:
=================================
// These settings override both User and Default settings for the Bash syntax
{
    "translate_tabs_to_spaces": true,
    "draw_minimap_border": true,
    "match_brackets_angle": true
}

EOF

###############################################
# Install ZSH
###############################################
ZSHRC_FILE=~/.zshrc
ZSHALIASES_FILE=~/.zsh_aliases
sudo apt-get -y install zsh

# change your terminal to use zsh by default
chsh -s `which zsh`

# Install oh-my-zsh for better looking terminal
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install pluggins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Uncomment the export PATH command at the beginig of he file
sed -i 's/#\(export PATH=$HOME\/bin:\/usr\local\/bin:$PATH\)/\1/' $ZSHRC_FILE

# ZSH_THEME="mh"
sed -i 's/ZSH_THEME.*/ZSH_THEME="mh"/' $ZSHRC_FILE

# Add pluggins
# zsh-syntax-highlighting must be the last plugin sourced
# plugins=(colored-man-pages git zsh-syntax-highlighting)
l=$(grep -n "plugins" $ZSHRC_FILE | cut -d':' -f1)
if [ -n "$(sed -n "$(($l + 1))p" $ZSHRC_FILE | grep ')' )" ]; then
    sed -i "$(($l + 1))d" $ZSHRC_FILE
    sed -i 's/plugins.*/plugins=(colored-man-pages git zsh-syntax-highlighting)/' $ZSHRC_FILE
fi

# add the following at the end of your zshrc file
cat << EOF >> $ZSHRC_FILE

# Aliases and aliases functions
~/.zsh_aliases
EOF

###############################################
# Create Alias file ~/.zsh_aliases
###############################################
# write in ~/.zsh_aliases (that you've just sourced in .zshrc) the following:
cat << EOF > $ZSHALIASES_FILE
# get you IPv6 link local IP address from ETH MAC
alias ipv6calc="ipv6calc --action prefixmac2ipv6 --in prefix+mac --out ipv6addr fe80::"

# Handy subprocess
alias gitk="gitk &"

# Handy hook functions (Aliases)
function git()
{
  if [[ $\# -gt 0 ]] && [[ "\$1" == "gui" ]]; then
     command gitg &
  else
     command git "$\@"
  fi
}
EOF

# the hook function allows you to use either `gitg` or `git gui` command for the same results.
# If your comming from Windows you're probably more use to `git gui`
# You can easally tweak this function to create new behaviours


###############################################
# SSH configuration
###############################################
# Generate Key
ssh-keygen -t rsa -b 1024


###############################################
# Git setup
###############################################
# Test now if the IT guy has your git access set up

# Configure local git info
git config --global user.name "Malcolm Dimeglio"
git config --global user.email johndoe@gmail.com
git config --global core.filemode true  # will track `chmod` modification
git config --global push.default simple

###############################################
# Install Beyond Compare for file diffs
###############################################
# Either go to the Ubuntu Software Center and look for 'bcompare'
# Or do it manually:
wget https://www.scootersoftware.com/bcompare-4.2.4.22795_amd64.deb
sudo apt-get -y update
sudo apt-get -y install gdebi-core
sudo gdebi bcompare-4.2.4.22795_amd64.deb


###############################################
# Install Wireshark
###############################################
# Add the stable official PPA
sudo add-apt-repository ppa:wireshark-dev/stable
sudo apt-get -y update
sudo apt-get -y install wireshark

# If you get a error couldn't run /usr/bin/dumpcap in child process: Permission Denied. go to the terminal again and run:
# sudo dpkg-reconfigure wireshark-common
# Say YES to the message box. This adds a wireshark group. Then add user to the group by typing
sudo adduser $USER wireshark
# Then restart your machine and open wireshark

echo
echo "Please reboot your computer"



