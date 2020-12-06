#!/usr/bin/env bash
# version 1.2.2
# user kany
# bash -n mytermux.sh

##################################################################################
# 相关资料
# awesome-bash https://github.com/awesome-lists/awesome-bash
# awesome-shell https://github.com/alebcay/awesome-shell
# Google's Shell Style Guide https://google.github.io/styleguide/shellguide.html#stdout-vs-stderr
# 高级Bash脚本编写指南 https://tldp.org/LDP/abs/html/
# Use Bash Strict Mode (Unless You Love Debugging) http://redsymbol.net/articles/unofficial-bash-strict-mode/
# ShellCheck，用于Shell脚本的静态分析工具 https://github.com/koalaman/shellcheck
# TODO :
# anthon https://mirrors.tuna.tsinghua.edu.cn/anthon/aosc-os/os-arm64/xfce/aosc-os_xfce_20200607_arm64.tar.xz https://www.coolapk.com/feed/17861928?shareKey=OGE0ZTJjMDU4ZDQ5NWZjOGNiZjY~&shareUid=3064572&shareFrom=com.coolapk.market_10.5.3
# https://mirrors.bfsu.edu.cn/lxc-images/images/ubuntu/hirsute/arm64/cloud/20201202_07%3A42/rootfs.tar.xz
# https://mirrors.bfsu.edu.cn/lxc-images/
# https://mirrors.tuna.tsinghua.edu.cn/lxc-images/streams/v1/images.json
# https://partner-images.canonical.com/core/disco/current/ubuntu-disco-core-cloudimg-arm64-root.tar.gz	
# https://partner-images.canonical.com/core/focal/current/ubuntu-focal-core-cloudimg-arm64-root.tar.gz
# bash /storage/emulated/0/Download/termux/mytermux.sh
# cp /storage/emulated/0/Download/termux/mytermux.sh mytermux.sh ; bash mytermux.sh
# perl https://qntm.org/perl_en http://www.perl.org/get.html
# kali https://www.kali.org/docs/nethunter/nethunter-rootless/
versionCode=8
versionName="1.2"
scriptName="mytermux"


set -euxo pipefail
#IFS=$'\n\t'

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}
############################
#if ! do_something; then           ##
#  err "Unable to do_something"  ##
#  exit 1                           ##
#fi                                 ##

#mypackage::my_func() {
# 
#}
###########################

mytermux_tool(){
    if (whiptail --title "安装必备工具" --yes-button "安装" --no-button "退出脚本"  --yesno  "安装如下工具：wget,git," 0 0); then
        pkg install wget git
        exit 0
    fi
}

main() {
    #alias rm="rm -i"
    set_terminal_color
    auto_check
    script_main_menu
}
auto_check() {
	case "$(uname -o)" in
	Android)
	    LINUX_DISTRO='Android'
		TERMUX_STORAGE='true'
		tmoe_manager_android_env # termux-setup-storage
		check_android_termux_whiptail # 检测 whiptail是否安装
		check_script_need_termux_tool 66 # 检测必备工具是否安装
		script_main_menu
		;;
	*)
		#tmoe_manager_gnu_linux_env
		# GNU/Linux
		echo "错误"
		#check_gnu_linux_distro
		;;
	esac
}
#TODO: 空4格，完善help，修复 bug ，掌握shift，更改MYTERMUX_MAIN_OPTION，修复自动返回主菜单

# termux-setup-storage
tmoe_manager_android_env() {
	if [ ! -h "${HOME}/storage/shared" ]; then
        if [ $(command -v termux-setup-storage) ]; then
	        termux-setup-storage
		else
			TERMUX_STORAGE='false'
		fi
	fi
}
# 检测 whiptail是否安装
check_android_termux_whiptail() {
	[[ -e ${PREFIX}/bin/whiptail ]] || install_android_whiptail
}
# 安装 whiptail
install_android_whiptail() {
	RETURN_TO_WHERE='exit'
	printf "Do you want to install" "whiptail(dialog)?"
	printf "apt install -y" "dialog"
	do_you_want_to_continue
	apt update
	apt install -y dialog
	[[ -e ${PREFIX}/bin/whiptail ]] || apt install -y whiptail
}
# 检测必备工具是否安装
check_script_need_termux_tool() {
    termux_tool_all="wget,git,proot"
    if [ $# -gt 0 ]; then
        case "$1" in
             termux_wget) [[ -e ${PREFIX}/bin/wget ]] || install_script_need_tool_menu termux_wget ;;
             termux_git) [[ -e ${PREFIX}/bin/git ]] || install_script_need_tool_menu termux_git ;;
             termux_proot) [[ -e ${PREFIX}/bin/proot ]] || install_script_need_tool_menu termux_proot ;;
             *) err "错误"
        esac 
    else 
        install_script_need_tool_menu ${termux_tool_all}    
    fi
}

# 安卓必备工具菜单
install_script_need_tool_menu() { 
    install_mytermux_tools="$1"
    MYTERMUX_MAIN_OPTION=$(
    whiptail --title "安装必备工具" \
            --backtitle "${scriptName}当前版本：$versionName" \
		    --menu "欢迎使用本工具\n请使用触摸屏或方向键+回车键进行操作" 0 0 0 \
			"1" "本脚本需安装：${install_mytermux_tools}" \
			"2" "先换源再安装" \
			"0" "🌚 exit 退出" \
			3>&1 1>&2 2>&3
	)
	case "${MYTERMUX_MAIN_OPTION}" in
	    0 | "") exit 0 ;;
	    1) install_mytermux_tool ${install_mytermux_tools} ;;
	    2) mytermux_change_repo an ;;
	    *) echo "输入不符合要求"
	esac
}
# 安装必备工具
install_mytermux_tool() {
#判断 $1 是否为空
    pkg install $1
    #script_main_menu
}

#########################################
# 主菜单
script_main_menu() {
    MYTERMUX_MAIN_OPTION=$(
	    whiptail --title "My Termux" \
	        --backtitle "${scriptName}当前版本：$versionName" \
		    --menu "欢迎使用本工具\n请使用触摸屏或方向键+回车键进行操作" 0 50 0 \
			"1" "Termux 换源" \
			"2" "PRoot容器" \
			"3" "修改常用按键" \
			"4" "终端美化" \
			"5" "开发环境" \
			"6" "ShellCheck -脚本静态分析工具" \
			"7" "Termux 图形界面" \
			"8" "更多" \
			"9" "更新" \
			"0" "🌚 exit 退出" \
			3>&1 1>&2 2>&3
	)
    case "${MYTERMUX_MAIN_OPTION}" in
	    0 | "") exit 0 ;;
	    1) mytermux_change_repo ;;
	    2) install_proot_container ;;
	    3) change_key ;;
	    4) mytermux_ohmyzsh ;;
	    5) development_environment ;;
	    6) termux_install_shellcheck ;;
	    7) termux_vnc_server ;;
	    8) termux_more_tool ;;
	    9) script_update ;;
	esac
}

#########################################
# 换源
mytermux_change_repo() {
    MYTERMUX_REPO_OPTION=$(
	    whiptail --title "换源" \
	        --backtitle "当前版本：$versionName" \
		    --menu "欢迎使用本工具\n请使用触摸屏或方向键+回车键进行操作" 0 50 0 \
			"1" "清华源" \
			"2" "其他源" \
			"3" "主菜单" \
			"0" "🌚 exit 退出" \
			3>&1 1>&2 2>&3
	)
    case "${MYTERMUX_REPO_OPTION}" in
        0 | "") exit 0 ;;
        1) 
          sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
          sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
          sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list
          pkg update
          if [ "$1" == "an" ]; then
              install_mytermux_tool
          fi
          script_main_menu
          ;;
        2) 
          termux-change-repo 
          if [ "$1" == "an" ]; then
              install_mytermux_tool
          fi
          script_main_menu
          ;;
        3) script_main_menu ;;
        *) echo "输入不符合要求" ;;
      esac
}

#########################################
# 安装 PRoot 容器
install_proot_container() {
    pkg install proot proot-distro
    #prootinstall="proot-distro install"
    MYTERMUX_MAIN_OPTION=$(
	    whiptail --title "安装 PRoot 容器" \
	        --backtitle "这里使用的 proot-distro 安装" \
		    --menu "欢迎使用本工具\n请使用触摸屏或方向键+回车键进行操作" 0 50 0 \
			"1" "Alpine Linux -最小的可用发行版。" \
			"2" "Arch Linux" \
			"3" "Kali Nethunter -当前只有最小的构建。" \
			"4" "Ubuntu 20.04" \
			"5" "Ubuntu 18.04" \
			"6" "proot-distro 帮助" \
			"7" "返回主菜单" \
			"0" "🌚 exit 退出" \
			3>&1 1>&2 2>&3
	)
    case "${MYTERMUX_MAIN_OPTION}" in
	    0 | "") exit 0 ;;
	    1) proot-distro install alpine ;;
	    2) proot-distro install archlinux ;;
	    3) proot-distro install nethunter ;;
	    4) proot-distro_ubuntu-20.04 ;;#proot-distro install ubuntu-20.04 ;;# ubuntu-20.04 ubuntu-18.04
	    5) proot-distro install ubuntu-18.04 ;;
	    6) proot-distro-help_zh ;;
	    7) script_main_menu ;;
	    *) echo "输入不符合要求"
	esac
}
proot-distro_ubuntu-20.04() {
    proot-distro install ubuntu-20.04
   #/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu-20.04
    CHANGE_DNS
    echo "修改为清华源"
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports bionic main restricted universe multiverse
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports bionic-security main restricted universe multiverse
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports bionic-updates main restricted universe multiverse
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports bionic-backports main restricted universe multiverse " >/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu-20.04/etc/apt/sources.list
    #修复源
    echo "fixing..."
		sleep 1
		sed -i "s/https/http/g" /etc/apt/sources.list 2>/dev/null
		apt update && apt install apt-transport-https ca-certificates -y && sed -i "s/http/https/g" /etc/apt/sources.list && apt update    
}
CHANGE_DNS() {
    my_ubuntu-20.04="${PREFIX}/var/lib/proot-distro/installed-rootfs/ubuntu-20.04/"
    if [ ! -L "${my_ubuntu-20.04}/etc/resolv.conf" ]; then
        echo "nameserver 223.5.5.5
    nameserver 223.6.6.6" > ${my_ubuntu-20.04}/etc/resolv.conf
        echo -e "已修改为223.5.5.5;223.6.6.6"          
        sleep 1
    elif [ -L "/etc/resolv.conf" ]; then
	    mkdir -p /run/systemd/resolve 2>/dev/null && echo "nameserver 223.5.5.5
        nameserver 223.6.6.6" >/run/systemd/resolve/stub-resolv.conf
        echo -e "已修改为223.5.5.5;223.6.6.6"
        sleep 1
    fi
}
# proot-distro 帮助
proot-distro-help_zh() {
    if (whiptail --title "这是可用的proot-distro功能的基本概述：" --yes-button "安装PRoot" --no-button "退出脚本"  --yesno  "1.proot-distro install -安装发行版\n2.proot-distro login -启动分发的根外壳。\n3.proot-distro remove -卸载发行版。\n4.proot-distro reset -重新安装发行版。" 0 0); then
        install_proot_container
        #exit 0
    fi
}
proot_ubuntu() {
    if [ -e rootfs.tar.xz ]; then
	    rm -rf rootfs.tar.xz
	fi
	CURL_T="https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/ubuntu/bionic/arm64/default/"
	curl -o rootfs.tar.xz ${CURL_T}
    SYSTEM_DOWN
    echo "修改为清华源"
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports bionic main restricted universe multiverse
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports bionic-security main restricted universe multiverse
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports bionic-updates main restricted universe multiverse
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports bionic-backports main restricted universe multiverse " >$bagname/etc/apt/sources.list
    sleep 2
}
SYSTEM_DOWN() {
    VERSION=`cat rootfs.tar.xz | grep href | tail -n 2 | cut -d '"' -f 4 | head -n 1`
    curl -o rootfs.tar.xz ${CURL_T}${VERSION}rootfs.tar.xz
    if [ $? -ne 0 ]; then
        echo -e "${RED_COLOR}下载失败，请重输${RES}\n"
        exit 0
        sleep 2
    fi
    echo -n "请给系统文件夹起个名bagname:"
    read bagname
    if [ -e $bagname ]; then
        rm -rf $bagname
    fi
    mkdir $bagname && tar xvf rootfs.tar.xz -C $bagname
    rm rootfs.tar.xz
    echo -e "系统已下载，文件夹名为$bagname"
    sleep 2
    echo "修改时区"
    sed -i "1i\export TZ='Asia/Shanghai'" $bagname/etc/profile
    echo "配置dns"                                 
    rm $bagname/etc/resolv.conf 2>/dev/null
    echo "nameserver 223.5.5.5
    nameserver 223.6.6.6" >$bagname/etc/resolv.conf
    echo -e "已修改为223.5.5.5;223.6.6.6"
    sleep 1
    if grep -q 'ubuntu' "$bagname/etc/os-release" ; then
        touch "$bagname/root/.hushlogin"
    fi
    echo "" >$bagname/proc/version
    pkg install pulseaudio
    echo "pulseaudio --start &
    unset LD_PRELOAD
    proot --kill-on-exit -S $bagname --link2symlink -b /sdcard:/root/sdcard -b /sdcard -b $bagname/proc/version:/proc/version -b $bagname/root:/dev/shm -w /root /usr/bin/env -i HOME=/root TERM=$TERM USER=root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games LANG=C.UTF-8 /bin/bash --login" >$bagname.sh && chmod +x $bagname.sh
    echo -e "已创建root用户系统登录脚本,登录方式为${YELLOW_COLOR}./$bagname.sh${RES}"
    if [ -e ${PREFIX}/etc/bash.bashrc ]; then
        if ! grep -q 'pulseaudio' ${PREFIX}/etc/bash.bashrc; then
            sed -i "1i\pkill -9 pulseaudio" ${PREFIX}/etc/bash.bashrc
        fi
    else
        sed -i "1i\pkill -9 pulseaudio" $bagname.sh
    fi
    ln -s ${HOME}/mytermux.sh $bagname/root/
    sleep 2
}
#########################################
#修改常用按键 待完善
change_key() {
    #RETURN_TO_WHERE='script_main_menu'
    if [ -d ${HOME}/.termux ]; then 
   # source ~/.termux/termux.properties
        termux_key
        echo "重新启动 Termux，可以看到效果 "
        exit 0
        
    else 
        mkdir ~/.termux
        termux_key
        echo "重新启动 Termux，可以看到效果 "
        exit 0
    fi
}

termux_key() {
    echo "extra-keys = [ \
           ['ESC','|','/','HOME','UP','END','PGUP','DEL'], \
           ['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN','BKSP'] \
          ]" > ~/.termux/termux.properties 
    #source ~/.termux/termux.properties
}
# 失败
termux_key_cat() {
    termux_properties="termux.properties"
cat > $termux_properties <<- EOM
extra-keys = [ \
 ['ESC','|','/','`','UP','QUOTE','APOSTROPHE'], \
 ['TAB','CTRL','~','LEFT','DOWN','RIGHT','ENTER'] \
]
EOM
}

#########################################
#终端美化 https://github.com/Cabbagec/termux-ohmyzsh/
mytermux_ohmyzsh() {
    pkg install git zsh
    git clone https://github.com/Cabbagec/termux-ohmyzsh.git "$HOME/termux-ohmyzsh" --depth 1
    mv "$HOME/.termux" "$HOME/.termux.bak.$(date +%Y.%m.%d-%H:%M:%S)"
    cp -R "$HOME/termux-ohmyzsh/.termux" "$HOME/.termux"
    git clone git://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh" --depth 1
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y.%m.%d-%H:%M:%S)"
    cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
    sed -i '/^ZSH_THEME/d' "$HOME/.zshrc"
    sed -i '1iZSH_THEME="agnoster"' "$HOME/.zshrc"
    echo "alias chcolor='$HOME/.termux/colors.sh'" >> "$HOME/.zshrc"
    echo "alias chfont='$HOME/.termux/fonts.sh'" >> "$HOME/.zshrc"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh-syntax-highlighting" --depth 1
    echo "source $HOME/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$HOME/.zshrc"
    chsh -s zsh
    echo "oh-my-zsh install complete!\nChoose your color scheme now~"
    $HOME/.termux/colors.sh
    echo "Choose your font now~"
    $HOME/.termux/fonts.sh
    echo "Please restart Termux app..."
    exit
}		

#########################################
# 开发环境
development_environment() {
    MYTERMUX_DEV_OPTION=$(
	    whiptail --title "开发环境" \
		    --menu "欢迎使用本工具\n请使用触摸屏或方向键+回车键进行操作" 0 50 0 \
			"1" "Java" \
			"2" "Python（会自动升级pip，并安装iPython，Jupyter Notebook）" \
			"3" "Kali Nethunter -当前只有最小的构建。" \
			"4" "Ubuntu 20.04" \
			"5" "proot-distro 帮助" \
			"6" "返回主菜单" \
			"0" "🌚 exit 退出" \
			3>&1 1>&2 2>&3
	)
	case "${MYTERMUX_DEV_OPTION}" in
	    0 | "") exit 0 ;;
	    1) install_java ;;
	    2) install_python ;;
	    3) proot-distro install nethunter ;;
	    4) proot-distro install ubuntu ;;
	    5) proot-distro-help_zh ;;
	    6) script_main_menu ;;
	    *) echo "输入不符合要求"
	esac
}
# 安装Java
install_java() {
    if  [ $(uname -m) != "aarch64" ]; then
	    echo "不支持的平台 无法安装 正在退出"
	    exit 1
    fi
    if  [ -x "$(command -v java)" ]; then
	    echo "jdk已安装，请检查"
	    exit 1
    fi
    if  [ -d jdk ];  then
        echo "已下载完成 正在配置环境变量"
    elif ! [ -f jdk.tar.gz ]; then 
	    echo "正在安装"
	  # 换成蓝奏云
	  #wget -c https://github.com/xiliuya/openjdk11-termux/releases/download/0.1/openjdk11.tar.gz -O jdk.tar.gz &&
	    echo "下载完成  正在解压" 
    fi
    tar -zxvf jdk.tar.gz &&
    rm -rf jdk.tar.gz &&
    vartmp1=$(cat $HOME/.bashrc | grep "export PATH=$PWD/jdk/bin/:\$PATH")
    if [ ! -n "$vartmp1" ] ; then 
	    echo export LD_LIBRARY_PATH=$PWD/jdk/lib/:$PWD/jdk/lib/jli/:$PWD/jdk/lib/server/ >> $HOME/.bashrc
	    echo export PATH=$PWD/jdk/bin/:\$PATH >> $HOME/.bashrc
    fi
    unset vartmp1
	echo "环境变量配置完成，请重启终端更新配置"
}
# 安装 Python
install_python() {
    RETURN_TO_WHERE="script_main_menu"
    pkg install python -y # 安装 Pytthon
    python -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple some-package #升级 pip
    echo "${GREEN}已安装 Python，将要安装 iPython，Jupyter"
    do_you_want_to_continue
    pip install ipython -i https://pypi.tuna.tsinghua.edu.cn/simple some-package  # 安装 iPython
    #pip3.8 install ipython -i https://pypi.tuna.tsinghua.edu.cn/simple some-package
    # 开始安装Jupyter Notebook
    pkg update
    # 安装必需工具
    pkg install proot
    # 切换模拟的 root 环境
    termux-chroot
    # 安装相关依赖
    apt install git clang
    apt install pkg-config
    apt install python python3-dev 
    apt install libclang libclang-dev
    apt install libzmq libzmq-dev
    #apt install ipython 
    #pip install jupyter 
    # 安装 jupyter
    pip install jupyter -i https://pypi.tuna.tsinghua.edu.cn/simple some-package
    # 安装完成退出 chroot
    exit
    # 安装 jupyterlab
    pip install jupyterlab -i https://pypi.tuna.tsinghua.edu.cn/simple some-package
    echo "启动请输入：jupyter notebook"
}

#########################################
# 静态脚本分析工具
termux_install_shellcheck() {
    if [[ -e ${PREFIX}/bin/shellcheck ]]; then
        echo "ShellCheck 已经安装"
        check_script_need_termux_tool termux_proot
        echo "已切换模拟的 root 环境，退出请输入exit"
        echo "shellcheck --version 查看版本"
        termux-chroot
    else 
        scversion="stable" # or "v0.4.7", or "latest"
        wget -qO- "https://github.com/koalaman/shellcheck/releases/download/${scversion?}/shellcheck-${scversion?}.linux.aarch64.tar.xz" | tar -xJv
        cp "shellcheck-${scversion}/shellcheck" $PREFIX/bin/
        echo "已切换模拟的 root 环境，退出请输入exit"
        check_script_need_termux_tool termux_proot
        termux-chroot
    fi
}

#########################################
# termux安装图形界面
termux_vnc_server() {
    echo "请安装 vnc-viewer"
    echo "蓝奏云地址 https://www.lanzous.com/b08f04a3g"
    echo "密码:ehbz"
    # 配置 vnc-server
    pkg i -y x11-repo ; pkg up -y ; pkg i -y xfce tigervnc openbox aterm
    # 720x1440(竖屏) 1920x1080(横屏)
    echo -e "#\!/bin/bash -e\nam start com.realvnc.viewer.android/com.realvnc.viewer.android.app.ConnectionChooserActivity\nexport DISPLAY=:1\nXvnc -geometry 720x1440 --SecurityTypes=None \$DISPLAY&\nsleep 1s\nopenbox-session&\nthunar&\nstartxfce4">~/startvnc
    chmod +x ~/startvnc ; mv -f ~/startvnc $PREFIX/bin/
    startvnc #启动 vnc-server
    echo "vnc-server 已启动"
    echo "启动命令 startvnc"
    echo "打开vnc viewer，输入localhost:5901"
    #TODO : url
}

#########################################
#更多功能
termux_more_tool() {
    SCRIPT_MAIN_OPTION=$(
    whiptail --title "更多" \
		    --menu "欢迎使用本工具\n请使用触摸屏或方向键+回车键进行操作" 0 0 0 \
			"1" "效果酷炫的 Linux 命令" \
			"2" "先换源再安装" \
			"0" "🌚 exit 退出" \
			3>&1 1>&2 2>&3
	)
	case "${MYTERMUX_DEV_OPTION}" in
	    0 | "") script_main_menu ;;
	    1) linux_shell ;;
	    2) install_python ;;
	    *) echo "输入不符合要求"
	esac
}
# 效果酷炫的 Linux 命令
# TODO : 
linux_shell() {
    SCRIPT_MAIN_OPTION=$(
    whiptail --title "效果酷炫的 Linux 命令" \
		    --menu "欢迎使用本工具\n请使用触摸屏或方向键+回车键进行操作" 0 0 0 \
			"1" "cmatrix -代码雨" \
			"2" "sl -火车" \
			"3" "htop -性能工具" \
			"4" "hollywood" \
			"5" "cal -日历" \
			"6" "cowsay -牛" \
			"7" "aafire -火焰字符串" \
			"8" "yes" \
			"9" "bastet -俄罗斯方块"
			"0" "🌚 exit 退出" \
			3>&1 1>&2 2>&3
	)
	case "${SCRIPT_MAIN_OPTION}" in
	    0 | "") script_main_menu ;;
	    1) linux_shell ;;
	    2) install_python ;;
	    *) echo "输入不符合要求"
	esac
}
#########################################
# 更新
script_update() {
    echo "已是最新版"
}

mytermux_test() {
    MYTERMUX_TEST_OPTION=$(
	    whiptail --title "开发环境" \
		    --menu "欢迎使用本工具\n请使用触摸屏或方向键+回车键进行操作" 0 50 0 \
			"1" "Java" \
			"2" "Python（会自动升级pip，并安装iPython，Jupyter Notebook）" \
			"3" "Kali Nethunter -当前只有最小的构建。" \
			"4" "Ubuntu 20.04" \
			"5" "proot-distro 帮助" \
			"0" "返回主菜单" \
			3>&1 1>&2 2>&3
	)
	case "${MYTERMUX_TEST_OPTION}" in
	    0 | "" ) script_main_menu ;;
	    1) install_java ;;
	    2) install_python ;;
	    3) proot-distro install nethunter ;;
	    4) proot-distro install ubuntu ;;
	    5) proot-distro-help_zh ;;
	    *) echo "输入不符合要求"
	esac
}

SETTLE() {
	echo -e "\n\e[0;35m1) 遇到关于Sub-process /usr/bin/dpkg returned an error code (1)错误提示
2) 安装个小火车(命令sl)
3) 增加普通用户并赋予sudo功能
4) 忽略Ubuntu出现的groups: cannot find name for group *提示
5) 设置时区
6) 安装进程树(可查看进程，命令pstree)
7) 安装网络信息查询(命令ifconfig)
8) 修改国内源地址sources.list(only for debian and ubuntu)
9) 修改dns
10) GitHub资源库(只支持debian和ubuntu)
11) python3和pip应用
12) 中文汉化
13) 安装系统信息显示(neofetch,screenfetch)"

}
myeof() {
cat <<-'EOF'
			-m      --更换为tuna镜像源(仅debian,ubuntu,kali,alpine和arch)
			-n      --启动novnc
			-v      --启动VNC
			-s      --停止vnc
			-x      --启动xsdl
			-h      --获取帮助信息
		EOF
}

# 判断返回主菜单还是退出
if_return_to_where_no_empty() {
	case ${RETURN_TO_WHERE} in
	    "") script_main_menu ;;
	    *) ${RETURN_TO_WHERE} ;;
	esac
}
# do_you_want_to_continue
do_you_want_to_continue() {
	printf "%s\n" "${YELLOW}Do you want to continue?[Y/n]${RESET}"
	printf "%s\n" "Press ${GREEN}enter${RESET} to ${BLUE}continue${RESET},type ${YELLOW}n${RESET} to ${BLUE}return.${RESET}"
	printf "%s\n" "按${GREEN}回车键${RESET}${BLUE}继续${RESET}，输${YELLOW}n${RESET}${BLUE}返回${RESET}"
	read opt
	case $opt in
	    y* | Y* | "") ;;
	    n* | N*)
		    printf "%s\n" "skipped."
		    if_return_to_where_no_empty
		    ;;
	    *)
		    printf "%s\n" "Invalid choice. skipped."
		    if_return_to_where_no_empty
		    ;;
	esac
}

function finish {
  # 在这里执行清理语句，例如，杀掉所有 fork 的进程。
  jobs -p | xargs kill
}
#trap finish EXIT

# 命令行颜色
set_terminal_color() {
	RED=$(printf '\033[31m')
	GREEN=$(printf '\033[32m')
	YELLOW=$(printf '\033[33m')
	BLUE=$(printf '\033[34m')
	BOLD=$(printf '\033[1m')
	PURPLE=$(printf '\033[0;35m')
	RESET=$(printf '\033[m')
}

set_terminal_color2() {
    BLACK="\033[0;30m"
    DARKGRAY="\033[1;30m"
	RED="\033[31m"
	TINT_RED="\033[1;31m"
	GREEN="\033[32m"
	TINT_GREEN="\033[1;32m"
	YELLOW="\033[33m"
	BLUE="\033[34m"
	TINT_BIUE="\033[1;34m"
	CYAN="\033[0;36m"
	TINT_CYAN="\033[0;36m"
	BOLD="\033[1m"
	PURPLE="\033[0;35m"
	RESET="'\033[m"
	TINT_GRAY="\033[0;37m"
	WHITE="\033[1;37m"
}
script_help() {
    echo "这是一个辣鸡脚本"
    echo "执行本脚本，请输入：bash mytermux.sh"
    echo "换源请输入 bash mytermux.sh repo"
    exit 0
}
if [ $# -ge 1 ]; then
	case "$1" in
		-h | --help | help) script_help ;;
		-r | --repo | repo ) mytermux_change_repo ;;
		myubuntu) proot_ubuntu ;;
		reset) shift 1; command_reset "$@";;
		login) shift 1; command_login "$@";;
		list) shift 1; command_list;;
		*)
			echo
			echo -e "Error: unknown command "
			echo
			echo -e "Run ' help' to see the list of available commands."
			echo
			exit 1
			;;
	esac
else
	#echo
	#echo -e "Error: no command provided"
	main
fi
exit 0






































#教程
##########################
#      大体思路:
    # 1.获取rootfs根文件系统
    # 2.写下proot脚本进入系统
    # 3.修改hosts，nameserver等等配置
    # 4.换源，运行包管理器
    # 5.清除缓存
    # 6.发布或者自己自己享用
# 
# 1.获取rootfs根文件系统的攻略，这里有以下几种方法
    # 1.翻找官方镜像源，或地区镜像源，当然，翻找的过程极其繁琐
      # 翻找的一些敲门:看架构类型，由于termux，主要arm64，所以找带arm64(aarch64)字眼的文件夹
      # 然后，找带base，rootfs之类的文件夹，甚至有些是丧心病狂的.rootfs隐藏文件夹，需要手动输入路径寻找
      # 最后，看看打包方式，一般.tar.gz，有的.tar.xz，有的.img.xz等等，这些一般是基础rootfs
    # 2.自己使用官方build脚本，使用有趣的文件等等
      # 这里deb系列推荐debootstrap，进行构建，有一些发行版，例如鹦鹉parrot系统，就是需要去Github手动下载parrot lts rolling等等(丧心病狂)
      # 类似于live-build啊等等，都是极好的工具，可以方便，迅速，快捷的构建出很好的系统，(有的需要实体机了)
    # 3.去官方镜像源，或地区镜像源，下载iso或者img文件，直接解包，去linux实体机，进行mount挂载提取文件
# 2.写proot脚本的攻略
    # 1.你可以执行proot，来获取帮助(英文，你的翻译器已经饥渴难耐。。)
    # 2.找现成的进行借鉴，当然，你可以使用anlinux脚本，可以使用kali nh，也可以使用我的此脚本(line 24-line 110):
    
          ########脚本如下
        # #!/data/data/com.termux/files/usr/bin/bash
        ##暂时删除termux的链接库变量，更兼容proot
        proot_rootfs() {
        unset LD_PRELOAD
        ##rootfs跟文件系统目录
        export RFSML=/data/data/com.termux/files/home/debianfs
        ##LANG系统语言变量，未设置时建议C
        export TLANG=zh_CN.UTF-8
        #登录shell
        export SHLX=bash
        #定义命令行
        command="
        proot \
            --kill-on-exit \
            --link2symlink \
            -0 \
            -r $RFSML \
            -b /dev \
            -b /proc \
            -b $RFSML/root:/dev/shm \
            -b /sdcard \
            -w /root \
              /usr/bin/env \
                -i HOME=/root \
                PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games \
                TERM=$TERM \
                LANG=$TLANG \
              /bin/$SHLX --login"
        #执行命令行
        test -z "$*" && exec $command || exec $command -c "$*"  
        }
        function 命令行注释(){
        echo '
        ##命令后面\是连接下一行，美观
        proot \
        #在proot环境中执行exit时，强制终止所有进程
            --kill-on-exit \
        #系统链接转换
            --link2symlink \
        #模拟登录用户，-0是root用户，-i uid:gid是模拟用户uid，gid，此概念可百度 -i 0:0等同于-0，因为root用户uid，gid都是0，你可以去/etc/passwd看看uid:gid
            -0 \
        #模拟新的根目录
            -r $RFSML \
        #模拟挂载手机的/dev /proc到rootfs
            -b /dev \
            -b /proc \
        #模拟挂载rootfs中的/root到/dev/shm
            -b $RFSML/root:/dev/shm \
        #模拟挂载手机的/sdcard到rootfs
            -b /sdcard \
        #定义工作目录
            -w /root \
        #执行env shell初始化
              /usr/bin/env \
        #修改HOME变量
                -i HOME=/root \
        #修改PATH变量
                PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games \
        #修改TEAM变量
                TERM=$TERM \
        #修改LANG变量
                LANG=$TLANG \
        #登录！
              /bin/$SHLX --login"
        #执行命令行
        exec $command
        ' 
        }
    # 此脚本功能齐全，可以做为proot启动脚本，注释很详细，上方有个小屋子，可以写下你的信息，使用vim或者neovim打开最佳
# 
# 3.修正nameserver等等，这些关乎于能否上网，域名能否正常解析。
    # echo "nameserver 127.0.1.1" > /etc/resolv.conf
    # echo "nameserver 8.8.8.8 " >> /etc/resolv.conf
# 4.换源，运行包管理器
    # 这个可以按照系统的不同进行切换
# 5.清除缓存
    # 同上
# 6.发布等等
    # 自己找渠道，想法
    # 
# 附录:
# 一些系统的rootfs获取方式
    # 1.debian,ubuntu,kali，可使用debootstrap
    # debootstrap --foreign --arch 架构 发行代号 rootfs目录 镜像源
    # 2.parrot也可以使用debootstrap，但是由于parrot源的特殊性，导致大部分源没有arm64
    # debootstrap --foreign --arch 架构 --components=main,contrib,non-free --include=apt-parrot,sysvinit-core lts rootfs存储目录 镜像源(一旦出现获取404，就是源不支持，已知yandex源支持)
    # 3.对于archlinux来说，镜像源里面包含有，例:清华源
    # https://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/os/ArchLinuxARM-aarch64-latest.tar.gz
    # 4.对于manjaro来说，一个丧心病狂的隐藏文件夹
    # https://mirrors.tuna.tsinghua.edu.cn/osdn/storage/g/m/ma/manjaro-arm/.rootfs/Manjaro-ARM-aarch64-latest.tar.gz
    # 5.对于Fedora来说，官方直接给了，可以参照此链接进行制作
    # https://kojipkgs.fedoraproject.org/packages/Fedora-Container-Base/Rawhide/20200418.n.0/images/Fedora-Container-Base-Rawhide-20200418.n.0.aarch64.tar.xz
    # 6.对于Alpine来说，镜像源也有了
    # https://mirrors.tuna.tsinghua.edu.cn/alpine/v3.9/releases/aarch64/alpine-minirootfs-3.9.5-aarch64.tar.gz
    # 7.对于anthon(安同)来说，镜像源也有了
    # https://mirrors.tuna.tsinghua.edu.cn/anthon/aosc-os/os-arm64/
    # 可以进入此链接进行挑选
    # 8.对于voidlinux来说，镜像源也存在了
    # https://mirrors.tuna.tsinghua.edu.cn/voidlinux/live/20191109/
    # 可以挑选
    # 9.对于slackware来说，你品，你细品
    # https://mirrors.tuna.tsinghua.edu.cn/slackwarearm/slackwarearm-devtools/minirootfs/roots/slack-current-miniroot_16Apr20.tar.xz
    # 10.对于deepin来说:哦，shit，由于莫得deepin arm64，但是，因为一些树莓派爱好者，我们可以从github发现，链接不给了，git这样搜索:deepin aarch64，那个Debian的就有[手动滑稽]
    # 11.对于有img的，有arm64(aarch64)的，我们可以使用实体机，使用file命令和电脑mount命令，进行解压img(ps:rootfs大多数在第二块分区，你可以瞅瞅)
  # 有了实体机一台，termux一个，我们就能创造出世界！termux，无敌(破音！)！
# 
# ps:termux可以这样:使用proot运行系统，使用qemu运行系统，有了root权限还能使用chroot运行系统，还可以利用termux dd刷机，还可以xxxxxx
# 
# 

#嗯。。当你看见anlinux那个rootfs，有没有感觉自己整是不是很爽？(很爽)
# 嗯，教程来了
# debootstrap --foreign --arch arm64 buster rootfs http://ftp.debian.org/debian/
# 看上面这个命令，debootstrap是制作rootfs命令，上面这个执行效果什么呢？在所在文件夹
# 生成一个rootfs的文件夹，这就是完整的rootfs了
# 
# 可能你懵懵的，来，看解释:
# --foreign就是不做配置(你是小白删了就行，爱动手的可以留着)
# --arch这个看字面意思就懂了，这就是定义系统架构，后面跟的arm64就是架构
# buster就是Linux发行版代号，这个代号是Debian10
# rootfs是rootfs存储目录
# http://ftp.debian.org/debian/是下载源
# 总体来说，这命令还是soeasy！
# 
# 执行完了之后你可能懵了，做好了怎么进去？？？？
# 嗯，我们这些小白可能不会造脚本，那就找到别人的脚本来进去！
# 你打开看anlinux那个脚本，你可以看见cat xxxxx EOM xxx EOM这样的，这就是脚本了！
# 当我们使用别人的系统，咋滴也得瞅瞅原理，来，让我们复制粘贴到终端！
# 粘贴好了之后，你就可以看见一个完整的，非常好看的脚本了(因为没配置脚本，直接执行是莫得作用的。。。)
# 
# 比如我这个脚本:
# 
# #!/bin/bash -e
# cd $(dirname $0)
# ## unset LD_PRELOAD in case termux-exec is installed
# unset LD_PRELOAD
# command="proot"
# command+=" --link2symlink"
# command+=" -0"
# command+=" -r /data/data/com.termux/files/home/rootfs"
# if [ -n "$(ls -A /data/data/com.termux/files/home/fs-bd)" ]; then
    # for f in /data/data/com.termux/files/home/fs-bd/* ;do
      # . $f
    # done
# fi
# command+=" -b /dev"
# command+=" -b /proc"
# command+=" -b /data/data/com.termux/files/home/rootfs/root:/dev/shm"
# ## 挂载termux HOME目录到 /root (建议关闭)
# #command+=" -b /data/data/com.termux/files/home:/root"
# ## 挂载手机/sdcard到 / (建议打开)
# command+=" -b /sdcard"
# command+=" -w /root"
# command+=" /usr/bin/env -i"
# command+=" HOME=/root"
# command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
# command+=" TERM=$TERM"
# ##修改语言
# command+=" LANG=zh_CN.UTF-8"
# ##修改默认命令行 ps:已美化
# command+=" /bin/bash --login"
# com="$@"
# if [ -z "$1" ];then
    # exec $command
# else
    # $command -c "$com"
# fi
# 
# 
# 整个脚本看来高大上
# /data/data/com.termux/files/home/rootfs这个是rootfs目录，看情况改就成
# /data/data/com.termux/files/home/fs-bd这个我也懵啊，应该构建目录，但是不影响使用
# 第一次启动先mkdir /data/data/com.termux/files/home/fs-bd
# 
# wow，我们的rootfsOK了，是时候拿出去装了！
# but...
# 你发现，好多功能都莫得作用
# 额。。。但其实这种完全没得毛病
# 看解决方法:
# 先执行:
# cd /var/cache/apt/archives/
# 接下来执行:
# dpkg --force-all -i *.deb
# 看到一堆堆报错忽略吧，莫得毛病
# 执行完了cd ~ 回到我们的Home
# 
# 你可能发现无法apt
# 解决方法:
# echo Debian /etc/hostname
# echo "127.0.0.1 Debian" >> /etc/hosts
# echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts
# mkdir /etc/network
# mkdir /etc/network/interfaces.d
# echo "auto eth0" > /etc/network/interfaces.d/eth0
# echo "iface eth0 inet dhcp" >> /etc/network/interfaces.d/eth0
# echo "nameserver 127.0.1.1" > /etc/resolv.conf
# echo "nameserver 8.8.8.8 " >> /etc/resolv.conf
# 
# 
# 在接下来:
# apt-get install -y udev sudo ssh --no-install-recommends 
# apt-get install -y systemd systemd-sysv dbus --no-install-recommends
# apt-get install -y ifupdown net-tools network-manager ethtool --no-install-recommends
# apt-get install -y vim udev sudo ssh git rsyslog bash-completion htop --no-install-recommends
# 
# 这些都是基本的工具啊什么的
# 在接下来自由发挥了，是拿去给别人玩还是自己造个系统玩玩
# 
# 
# 进阶教程:
# command+=" -q qemu-xxx-static"添加这个可以跨架构运行rootfs
# qemu-xxx-static就是qemu-user-static，可以自己编译，也可以Github下载
# 
# 
# 附注:
# 当出现处理软件包 gvfs:arm64 (--configure)时出错：等信息的时候，不要慌，见下列脚本
# 一条条执行就成
# mv /var/lib/dpkg/info /var/lib/dpkg/info_bak
# mkdir /var/lib/dpkg/info
# apt-get update && apt-get -f install 
# mv /var/lib/dpkg/info/* /var/lib/dpkg/info_bak/
# rm -rf /var/lib/dpkg/info
# mv /var/lib/dpkg/info_bak /var/lib/dpkg/info
# 
# 
# 
# 
# 注意:
# 本教程所用的命令，适用于Deb系系统，就是使用apt的
# #
# #
# #
#
#
#
#
#
#
#
#




