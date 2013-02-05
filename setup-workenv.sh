#! /bin/bash
set -e
set -u
# set -x

echo '* Updating to latest versions ...'
# sudo apt-get -y update  > /dev/null
# sudo apt-get -y dist-upgrade > /dev/null
echo '  ... done.'

echo '* Installing build-essential ...'
sudo apt-get install -y build-essential > /dev/null
echo '  ... done.'

echo '* Installing tools to fetch software and stuff ...'
for tool in aptitude git-core subversion subversion-tools wget curl mercurial rsync lftp s3cmd;
do
	echo "  - ${tool}"
	sudo apt-get -y install ${tool} > /dev/null
done
echo '  ... done.'

echo '* Installing system information tools ...'
for tool in htop bmon iftop iotop dstat;
do
	echo "  - ${tool}"
	sudo apt-get -y install ${tool} > /dev/null
done
echo '  ... done.'

echo '* Installing basic system tools ...'
for tool in ack;
do
	echo "  - ${tool}"
	sudo apt-get -y install ${tool} > /dev/null
done
echo '  ... done.'


echo '* Installing tools for terminal usage ...'
for tool in mc pv unp rar p7zip-full pbzip2 screen tmux terminator;
do
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

echo '* Installing developer tools ...'
for tool in kdiff3 wireshark htop dstat bmon iftop;
do
	echo "  - ${tool}"
	sudo apt-get -y install ${tool} > /dev/null
done
echo '  ... done.'


echo '* Preparing basic SSH dir for user '${USER} ...
pushd $HOME > /dev/null
if [ ! -d .ssh ]
then
    mkdir .ssh > /dev/null
    chmod 700 .ssh /dev/null
fi
if [ ! -f .ssh/config ]
then
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
# read -p ' git full user name (for message): ' GITUSERNAME
# git config --global user.name "${GITUSERNAME}"
# read -p ' git user email (for message): ' GITUSEREMAIL
# git config --global user.email "${GITUSEREMAIL}"
# git config --global core.editor 'emacs24-nox'
# git config --global color.ui true
echo '  ... done.'

echo '* Doing some settings ...'
echo '  - Disabling overlay scollbars'
echo "export LIBOVERLAY_SCROLLBAR=0" >> ${HOME}/.xprofile
echo '  - Setting up my bash extra settings'
if [ ! -f ${HOME}/.bash_extras ]
then
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
