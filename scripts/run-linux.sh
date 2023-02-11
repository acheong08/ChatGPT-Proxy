#!/bin/sh

# Check for the distribution
distribution=$(lsb_release -is)

# Function to install git with https support on different distributions
install_git() {
    case "$distribution" in
    Ubuntu | Debian)
        sudo apt-get update
        sudo apt-get install -y git libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev
        ;;
    CentOS)
        sudo yum update
        sudo yum install -y git curl-devel expat-devel gettext-devel openssl-devel zlib-devel
        ;;
    Fedora)
        sudo dnf update
        sudo dnf install -y git curl-devel expat-devel gettext-devel openssl-devel zlib-devel
        ;;
    *)
        echo "Unsupported distribution. Please install git with https support manually."
        exit 1
        ;;
    esac
}

# Function to install Chromium browser on different distributions
install_chromium() {
    case "$distribution" in
    Ubuntu | Debian)
        architecture=$(dpkg --print-architecture)
        chrome_deb="google-chrome-stable_current_${architecture}.deb"
        wget https://dl.google.com/linux/direct/$chrome_deb
        sudo dpkg -i $chrome_deb
        sudo apt-get install -y -f
        rm $chrome_deb
        ;;
    CentOS)
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

install_git
install_chromium

if [ -d "~/.local/shared/chatgpt-proxy-service" ]; then
    echo -e "Found existing ChatGPT-Proxy. Removing..."
    rm -rf ~/.local/shared/chatgpt-proxy-service
fi
mkdir -p ~/.local/shared/chatgpt-proxy-service

git clone https://github.com/fred913/ChatGPT-Proxy.git ~/.local/shared/chatgpt-proxy-service

cd ~/.local/shared/chatgpt-proxy-service

if command -v pip3 &>/dev/null; then
    pip3 install -U pipenv
else
    if command -v python3 &>/dev/null; then
        python3 -m pip install -U pipenv
    fi
fi

if ! command -v pipenv &>/dev/null; then
    echo -e "Pipenv not installed. Please install it manually..."
    exit 1
fi

pipenv update
pipenv run proxy
