#!/data/data/com.termux/files/usr/bin/bash

if [ -z "$TERMUX_VERSION" ]; then
    echo "请在 Termux 环境下运行此脚本。"
    exit 1
fi

# Change termux apt source to tsinghua mirror
echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main" > $PREFIX/etc/apt/sources.list

# Change motd
MOTD=/data/data/com.termux/files/usr/etc/motd
cat > $MOTD << 'EOF'
Welcome to Termux!
EOF
# Change bashrc
BASHRC=/data/data/com.termux/files/home/.bashrc
cat > $BASHRC << 'EOF'
echo -e "\033[1;38;5;21m  _____   _____   ____    __  __   _   _  __  __ \033[0m"
echo -e "\033[1;38;5;27m |_   _| | ____| |  _ \  |  \/  | | | | | \ \/ / \033[0m"
echo -e "\033[1;38;5;33m   | |   |  _|   | |_) | | |\/| | | | | |  \  /  \033[0m"
echo -e "\033[1;38;5;39m   | |   | |___  |  _ <  | |  | | | |_| |  /  \  \033[0m"
echo -e "\033[1;38;5;45m   |_|   |_____| |_| \_\ |_|  |_|  \___/  /_/\_\ \033[0m $TERMUX_VERSION"
PhoneModel="$(getprop ro.product.manufacturer) $(getprop ro.product.brand) $(getprop ro.product.model) ($(getprop ro.product.device)) $(getprop ro.build.version.release)"
echo $PhoneModel
uname -r
uname -osm
ifconfig 2>/dev/null | awk '/^[a-z0-9]+:/{dev=$1} /inet/&&$2!="127.0.0.1"{print dev,$2"/"$4}'
date "+%Y %b %d %a %H:%M:%S %Z(%:z)"
export PS1="$PS1\[\e]1337;CurrentDir="'$(pwd)\a\]'
EOF

apt update
apt install termux-auth termux-services openssh -y
sshd

# Init storage dir
STORAGE_DIR=/storage/emulated/0/
if [ -r "$STORAGE_DIR" ]; then
    if [ ! -L $HOME/0 ]; then
        ln -s $STORAGE_DIR $HOME/0
    fi
else
    read -p "是否开启存储权限?(y/n)"
    if [ "$REPLY" == "y" ]; then
        termux-setup-storage
        while [ ! -r "$STORAGE_DIR" ]; do
            sleep 1
        done
        rm -rf $HOME/storage
        ln -s $STORAGE_DIR $HOME/0
    fi
fi

# Show username
echo "Username: $(whoami)"
# Change password
echo "Please change password:"
passwd

clear

cat $MOTD
bash $BASHRC
echo "Username: $(whoami)"
