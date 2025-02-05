#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/kaleido.sh"

# 检查是否以 root 用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以 root 用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到 root 用户，然后再次运行此脚本。"
    exit 1
fi

# 安装和配置 kaleido 函数
function setup_kaleido() {
    # 检查 kaleido 目录是否存在，如果存在则删除
    if [ -d "kaleido" ]; then
        echo "检测到 kaleido 目录已存在，正在删除..."
        rm -rf kaleido
        echo "kaleido 目录已删除。"
    fi

    echo "正在从 GitHub 克隆 kaleido 仓库..."
    git clone https://github.com/sdohuajia/kaleido.git
    if [ ! -d "kaleido" ]; then
        echo "克隆失败，请检查网络连接或仓库地址。"
        exit 1
    fi

    cd "kaleido" || { echo "无法进入 kaleido 目录"; exit 1; }

    # 安装 Node.js 和 npm（如果尚未安装）
    if ! command -v npm &> /dev/null; then
        echo "正在安装 Node.js 和 npm..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi

    # 安装 npm 依赖项
    echo "正在安装 npm 依赖项..."
    npm install || { echo "npm 依赖项安装失败"; exit 1; }

    # 获取 token 和其他信息
    read -p "请输入0x钱包地址address: " address

    # 将信息保存到 wallets.txt 文件
    echo "${address}" >> wallets.txt
    echo "信息已保存到 wallets.txt"

    echo "正在使用 screen 启动 index.js..."
    screen -S kaleido -dm  # 创建新的 screen 会话，名称为 kaleido
    sleep 2  # 等待1秒钟确保会话已启动

    # 进入目录并启动 Node.js
    screen -S kaleido -X stuff "cd /root/kaleido && npm start\n" 
    echo "使用 'screen -r kaleido' 命令来查看日志。"
    echo "要退出 screen 会话，请按 Ctrl+A+D。"

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
}

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1. 部署kaleido节点 "
        echo "2. 退出"

        read -p "请输入您的选择 (1,2): " choice
        case $choice in
            1)
                setup_kaleido  # 调用安装和配置函数
                ;;   
            2)
                echo "退出脚本..."
                exit 0
                ;;
            *)
                echo "无效的选择，请重试."
                read -n 1 -s -r -p "按任意键继续..."
                ;;
        esac
    done
}

# 进入主菜单
main_menu
