#!/bin/bash

# 函数：检查Go版本是否符合要求
check_go_version() {
    if command -v go &> /dev/null; then
        INSTALLED_GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
        REQUIRED_GO_VERSION="1.22.3"
        # 比较当前Go版本与1.22.3
        if [ "$(printf '%s\n' "$REQUIRED_GO_VERSION" "$INSTALLED_GO_VERSION" | sort -V | head -n1)" = "$REQUIRED_GO_VERSION" ]; then
            echo "Go version $INSTALLED_GO_VERSION is already installed and meets the requirement."
            return 0
        else
            echo "Go version is less than 1.22.3, upgrading..."
            return 1
        fi
    else
        echo "Go is not installed. Installing Go 1.22.3..."
        return 1
    fi
}

# 函数：安装Go 1.22.3
install_go() {
    wget https://go.dev/dl/go1.22.3.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz
    echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
    source ~/.profile
}

# 检查Go版本并安装（如果需要）
if ! check_go_version; then
    install_go
fi

# Step 1: 下载 wardend 二进制文件并解压
echo "Downloading Warden binary..."
curl -L https://github.com/warden-protocol/wardenprotocol/releases/download/v0.4.2/wardend_Linux_x86_64.zip -o wardend_Linux_x86_64.zip

# 检查文件是否下载成功
if [ ! -f wardend_Linux_x86_64.zip ]; then
    echo "Download failed! Exiting..."
    exit 1
fi

# 检查文件大小
FILE_SIZE=$(stat -c%s "wardend_Linux_x86_64.zip")
echo "Downloaded file size: $FILE_SIZE bytes"

if [[ $FILE_SIZE -lt 1000 ]]; then
    echo "Downloaded file is too small, possibly an error page. Exiting..."
    exit 1
fi

echo "Extracting Warden binary..."
unzip wardend_Linux_x86_64.zip || { echo "Extraction failed! Exiting..."; exit 1; }
chmod +x wardend

# 将wardend移动到全局可用目录
sudo mv wardend /usr/local/bin/

# Step 2: 初始化节点主目录
echo "Initializing Warden node..."
wardend init my-chain-moniker

# Step 3: 获取 genesis.json 文件
echo "Fetching genesis.json file..."
wget https://buenavista-genesis.s3.amazonaws.com/genesis.json -O ~/.wardend/config/genesis.json

# Step 4: 配置最低Gas费用和持久化连接
echo "Configuring minimum gas prices and persistent peers..."
sed -i -e "s/minimum-gas-prices = \".*\"/minimum-gas-prices = \"0.025stake\"/g" ~/.wardend/config/app.toml

# Step 5: 启动节点
echo "Starting Warden node..."
wardend start

echo "Warden node setup completed!"
