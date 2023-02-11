apt install wget -y

architecture=$(dpkg --print-architecture)
chrome_deb="google-chrome-stable_current_${architecture}.deb"
wget https://dl.google.com/linux/direct/$chrome_deb
apt install -y ./$chrome_deb
apt-get install -y -f
rm $chrome_deb