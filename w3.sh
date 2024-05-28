#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 脚本保存路径
SCRIPT_PATH="$HOME/w3.sh"

## 安装环境
# 检查并安装 Node.js 和 npm
function install_nodejs_and_npm() {
    if command -v node > /dev/null 2>&1; then
        echo "Node.js 已安装"
    else
        echo "Node.js 未安装，正在安装..."
        curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi

    if command -v npm > /dev/null 2>&1; then
        echo "npm 已安装"
    else
        echo "npm 未安装，正在安装..."
        sudo apt-get install -y npm
    fi
}

# 检查并安装 PM2
function install_pm2() {
    if command -v pm2 > /dev/null 2>&1; then
        echo "PM2 已安装"
    else
        echo "PM2 未安装，正在安装..."
        npm install pm2@latest -g
    fi
}

# 检查Go环境
function check_go_installation() {
    if command -v go > /dev/null 2>&1; then
        echo "Go 环境已安装"
        return 0 
    else
        echo "Go 环境未安装，正在安装..."
        return 1 
    fi
}

function install_storage_node() {

    sudo apt-get update
    sudo apt-get install clang cmake build-essential git screen cargo -y


# 安装Go
    sudo rm -rf /usr/local/go
    curl -L https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    source $HOME/.bash_profile

    
# 克隆仓库
cd /pt/0g/
git clone -b v0.2.0 https://github.com/0glabs/0g-storage-node.git

#进入对应目录构建
cd 0g-storage-node
git submodule update --init

# 构建代码
cargo build --release

#后台运行
cd run


read -p "请输入你想导入的EVM钱包私钥，不要有0x: " minerkey

sed -i "s/miner_key = \"\"/miner_key = \"$minerkey\"/" config.toml
sed -i 's|blockchain_rpc_endpoint = "https://rpc-testnet.0g.ai"|blockchain_rpc_endpoint = "https://evm-rpc-0gchain.dadunode.com"|g' config.toml
sed -i 's/log_sync_start_block_number = 80981/log_sync_start_block_number = 223989/' config.toml


screen -dmS zgs_node_session ../target/release/zgs_node --config config.toml

echo '====================== 安装完成 ==========================='
echo '===进入对应路径:/0g-storage-node/run/log，使用tail -f logs文件名，查看logs 即可========================'

}

