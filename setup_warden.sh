#!/bin/bash

# Step 1: 下载 warden 二进制文件并解压
echo "Downloading Warden binary..."
curl -L https://github.com/warden-protocol/warden/releases/download/v0.4.2/warden_linux_amd64.tar.gz -o warden_linux_amd64.tar.gz
tar -xzvf warden_linux_amd64.tar.gz
chmod +x warden

# Step 2: 初始化节点主目录
echo "Initializing Warden node..."
./warden init my-chain-moniker

# Step 3: 获取 genesis.json 文件
echo "Fetching genesis.json file..."
wget https://buenavista-genesis.s3.amazonaws.com/genesis.json -O ~/.warden/config/genesis.json

# Step 4: 配置最低Gas费用和持久化连接
echo "Configuring minimum gas prices and persistent peers..."
sed -i -e "s/minimum-gas-prices = \".*\"/minimum-gas-prices = \"0.025stake\"/g" ~/.warden/config/app.toml

# Step 5: 启动节点
echo "Starting Warden node..."
./warden start

echo "Warden node setup completed!"
