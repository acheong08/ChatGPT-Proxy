#!/bin/sh

distribution=$(grep -Ei '^ID=' /etc/os-release | awk -F= '{print $2}')

if ! command -v sudo &>/dev/null; then
    # Docker container usually does not have a sudo command
    alias sudo=""
fi

install_git() {
    case "$distribution" in
    ubuntu | debian)
        sudo apt-get update
        sudo apt-get install -y git libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev
        ;;
    centos)
        sudo yum update
        sudo yum install -y git curl-devel expat-devel gettext-devel openssl-devel zlib-devel
        ;;
    fedora)
        sudo dnf update
        sudo dnf install -y git curl-devel expat-devel gettext-devel openssl-devel zlib-devel
        ;;
    *)
        echo "Unsupported distribution. Please install git with https support manually."
        exit 1
        ;;
    esac
}

install_chromium() {
    case "$distribution" in
    ubuntu | debian)
        architecture=$(dpkg --print-architecture)
        chrome_deb="google-chrome-stable_current_${architecture}.deb"
        wget https://dl.google.com/linux/direct/$chrome_deb
        sudo dpkg -i $chrome_deb
        sudo apt-get install -y -f
        rm $chrome_deb
        ;;
    centos)
        # Create the Chrome repository
        sudo sh -c "echo '[google-chrome]\nname=google-chrome\nbaseurl=http://dl.google.com/linux/chrome/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\ngpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub' > /etc/yum.repos.d/google-chrome.repo"

        # Update the system and install Chromium
        sudo yum update
        sudo yum install google-chrome-stable
        ;;
    *)
        echo "Unsupported distribution. Please install Chromium browser manually."
        exit 1
        ;;
    esac
}

install_python3() {
    case "$distribution" in
    ubuntu | debian)
        sudo apt-get update
        sudo apt-get install -y python3
        ;;
    centos)
        sudo yum update
        sudo yum install -y python3
        ;;
    fedora)
        sudo dnf update
        sudo dnf install -y python3
        ;;
    *)
        echo "Unsupported distribution. Please install Python 3 manually."
        exit 1
        ;;
    esac
}

if ! command -v git &>/dev/null; then
    echo Installing Git
    install_git
fi
if ! command -v chrome &>/dev/null; then
    echo Installing Chromium | Chrome
    install_chromium
fi

if [ -d "~/.local/shared/chatgpt-proxy-service" ]; then
    echo "Found existing ChatGPT-Proxy. Removing..."
    rm -rf ~/.local/shared/chatgpt-proxy-service
fi
mkdir -p ~/.local/shared/chatgpt-proxy-service

git clone https://github.com/fred913/ChatGPT-Proxy.git ~/.local/shared/chatgpt-proxy-service

cd ~/.local/shared/chatgpt-proxy-service

if command -v pip3 &>/dev/null; then
    pip3 install -U pipenv
else
    if ! command -v python3 &>/dev/null; then
        install_python3
    fi
    python3 -m pip install -U pipenv
fi

if ! command -v pipenv &>/dev/null; then
    echo "Pipenv not installed. Please install it manually..."
    exit 1
fi

pipenv update
# pipenv run proxy
echo "\n\nalias chatgptproxy=\"bash -c \\\"cd ~/.local/shared/chatgpt-proxy-service && pipenv run proxy\\\"\"\n\n" >~/.profile
echo "\n\nalias chatgptproxy=\"bash -c \\\"cd ~/.local/shared/chatgpt-proxy-service && pipenv run proxy\\\"\"\n\n" >~/.bashrc

echo "Installation successful! Use 'chatgptproxy' command to start up."
