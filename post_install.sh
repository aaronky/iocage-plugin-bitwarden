#!/bin/sh

# Create bitwarden User

# install latest rust version, pkg version is outdated and can't build bitwarden_rs
"curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

# Install Bitwarden_rs
mkdir -p /usr/local/share/bitwarden/src
git clone https://github.com/dani-garcia/bitwarden_rs/ /usr/local/share/bitwarden/src
TAG=$("git -C /usr/local/share/bitwarden/src tag --sort=v:refname | tail -n1")
"git -C /usr/local/share/bitwarden/src checkout ${TAG}"

"cd /usr/local/share/bitwarden/src && $HOME/.cargo/bin/cargo build --features mysql --release"
"cd /usr/local/share/bitwarden/src && $HOME/.cargo/bin/cargo install diesel_cli --no-default-features --features mysql"
cp -r /usr/local/share/bitwarden/src/target/release /usr/local/share/bitwarden/bin

# Download and install webvault
WEB_RELEASE_URL=$(curl -Ls -o /dev/null -w "%{url_effective}" https://github.com/dani-garcia/bw_web_builds/releases/latest)
WEB_TAG="${WEB_RELEASE_URL##*/}"
"fetch http://github.com/dani-garcia/bw_web_builds/releases/download/$WEB_TAG/bw_web_$WEB_TAG.tar.gz -o /usr/local/share/bitwarden"
"tar -xzvf /usr/local/share/bitwarden/bw_web_$WEB_TAG.tar.gz -C /usr/local/share/bitwarden/"
rm /usr/local/share/bitwarden/bw_web_"$WEB_TAG".tar.gz

chmod u+x /usr/local/etc/rc.d/bitwarden
sysrc "bitwarden_enable=YES"