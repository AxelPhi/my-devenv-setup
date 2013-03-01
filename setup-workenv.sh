#! /bin/bash
set -e
set -u
# set -x

## Set some variables
SKYPE_DOWNLOAD_URL="http://www.skype.com/go/getskype-linux-beta-ubuntu-64"

## For non-interactive setup set these ...
# GITUSERNAME=""
# GITUSEREMAIL=""

## Set to 0 if you don't want to install the Gnome-Shell desktop environment
INSTALL_GNOME_SHELL=1

## Start working
echo '* Updating to latest versions ...'
sudo apt-get -y update  > /dev/null
sudo apt-get -y dist-upgrade > /dev/null
echo '  ... done.'

echo '* Installing build-essential ...'
sudo apt-get install -y build-essential > /dev/null
echo '  ... done.'

echo '* Installing tools to fetch software and stuff ...'
for tool in aptitude git-core subversion subversion-tools wget curl mercurial rsync lftp s3cmd; do
	echo "  - ${tool}"
	sudo apt-get -y install ${tool} > /dev/null
done
echo '  ... done.'

echo '* Adding PPAs ...'
for ppa in ppa:tiheum/equinox ppa:gnome3-team/gnome3 ppa:webupd8team/themes; do
	echo "  - ${ppa}"
	sudo apt-add-repository -y ${ppa} > /dev/null
done
echo "  - Google Chrome"
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' > /dev/null
echo '  ... done.'
echo '* Updating repositories after adding PPAs ...'
sudo apt-get -y update > /dev/null
echo '  ... done.'


echo '* Installing system information tools ...'
for tool in htop bmon iftop iotop dstat; do
	echo "  - ${tool}"
	sudo apt-get -y install ${tool} > /dev/null
done
echo '  ... done.'

echo '* Installing basic system tools ...'
for tool in ack; do
	echo "  - ${tool}"
	sudo apt-get -y install ${tool} > /dev/null
done
echo '  ... done.'


echo '* Installing tools for terminal usage ...'
for tool in mc pv unp rar p7zip-full pbzip2 screen tmux terminator; do
	echo "  - ${tool}"
	sudo apt-get -y install ${tool} > /dev/null
done
echo '  ... done.'
echo '* Setting terminator as default terminal emulator ...'
sudo update-alternatives --set x-terminal-emulator /usr/bin/terminator
echo '  ... done.'

echo '* Installing x-less emacs and adding Prelude pacakge...'
sudo apt-get -y install emacs24-nox > /dev/null
# curl -L https://github.com/bbatsov/prelude/raw/master/utils/installer.sh | sh
echo '  ... done.'

echo '* Installing communication tools ...'
for tool in thunderbird thunderbird-lightning thunderbird-enigmail pidgin pidgin-otr xchat xchat-otr; do
	echo "  - ${tool}"
	sudo apt-get -y install ${tool} > /dev/null
done
echo '  - Skype'
pushd /tmp
wget -O ./skype.deb ${SKYPE_DOWNLOAD_URL}  > /dev/null
## Skype will fail due to missing dependencies. The next
## apt-get command will fix that, but we need to disable "-e" 
## for it temporarily.
set +e
sudo dpkg -i ./skype.deb &> /dev/null
set -e

sudo apt-get -y -f install > /dev/null
popd

echo '  ... done.'

echo '* Installing developer tools ...'
for tool in kdiff3 wireshark htop dstat bmon iftop; do
	echo "  - ${tool}"
	sudo apt-get -y install ${tool} > /dev/null
done
echo '  ... done.'

if [[ ${INSTALL_GNOME_SHELL} = "1" ]]; then

    echo '* Installing gnome shell desktop environment ...'
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ubuntu-gnome-desktop ubuntu-gnome-default-settings gnome-documents > /dev/null
    sudo apt-get -y remove ubuntu-settings > /dev/null
    sudo update-rc.d lightdm remove
    sudo update-rc.d gdm defaults
    echo '  ... done.'

fi

echo '* Installing look and feel packages ...'
for tool in faience-theme faience-icon-theme mediterraneannight-gtk-theme; do
	echo "  - ${tool}"
	sudo apt-get -y install ${tool} > /dev/null
done
echo '  ... done.'

echo '* Preparing basic SSH dir for user '${USER} ...
pushd $HOME > /dev/null
if [ ! -d .ssh ]; then
    mkdir .ssh > /dev/null
    chmod 700 .ssh > /dev/null
fi
if [ ! -f .ssh/config ]; then
    cat > .ssh/config <<EOF
## SSH client config

## Set some defaults

## Usually we want this.
Compression yes

## Enable this on a per-case base.
ForwardAgent no

## Template for new hosts
# Host <label>
#      Hostname        <hostname or ip>
#      Port            22
#      User            <user>
#      PubkeyAuthentication <yes|no>
#      IdentityFile    ~/.ssh/<path to private key>
#      ForwardX11      <yes|no>
#      ForwardAgent    <yes|no>

EOF
chmod 600 .ssh/config > /dev/null
fi
popd > /dev/null

echo '* Doing basic git configuration for user '${USER} ...
if [[ -z "$GITUSERNAME" ]]; then
    read -p ' git full user name (for message): ' GITUSERNAME
fi
git config --global user.name "${GITUSERNAME}"
if [[ -z "$GITUSEREMAIL" ]]; then
    read -p ' git user email (for message): ' GITUSEREMAIL
fi
git config --global user.email "${GITUSEREMAIL}"
git config --global core.editor 'emacs'
git config --global color.ui true
KDIFF3PATH=$(which kdiff3)
cat >> ${HOME}/.gitconfig <<EOF

[difftool "kdiff3"]
    path = ${KDIFF3PATH}
    trustExitCode = false

[difftool]
    prompt = false

[diff]
    tool = kdiff3

[mergetool "kdiff3"]
    path = ${KDIFF3PATH}
    trustExitCode = false

[mergetool]
    keepBackup = false

[merge]
    tool = kdiff3

EOF
echo '  ... done.'

echo '* Doing some settings ...'
echo '  - Disabling overlay scollbars'
echo "export LIBOVERLAY_SCROLLBAR=0" >> ${HOME}/.xprofile
echo '  - Setting up my bash extra settings'
if [ ! -f ${HOME}/.bash_extras ]; then
cat > ${HOME}/.bash_extras <<EOF
# We know that terminator supports this
export TERM=xterm-256color
EOF
fi
cat >> ${HOME}/.bashrc <<EOF
## Check if our own bash settings can be included
if [ -f ~/.bash_extras ]; then
    . ~/.bash_extras
fi
EOF
echo '  ... done.'
