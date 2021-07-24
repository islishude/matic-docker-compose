#!/bin/bash

set -ex

export DATA_DIR=/data
if [[ ! -d $DATA_DIR/bor ]]; then
    wget -O genesis.json https://raw.githubusercontent.com/maticnetwork/launch/master/mainnet-v1/without-sentry/bor/genesis.json
    bor init --datadir $DATA_DIR genesis.json
    rm genesis.json

    bootnode -genkey $DATA_DIR/bor/nodekey
fi

if [[ ! -f $DATA_DIR/key.txt ]]; then
    head -c 16 /dev/urandom | base64 >$DATA_DIR/key.txt
    ADDRESS=$(bor account new --datadir $DATA_DIR --password $DATA_DIR/key.txt 2>/dev/null | awk -v FS="({|})" '{print $2}')
else
    ADDRESS=$(bor account list --datadir $DATA_DIR 2>/dev/null | head -n 1 | awk -v FS="({|})" '{print $2}')
fi

exec bor --datadir $DATA_DIR \
    --port 30303 \
    --http --http.addr '0.0.0.0' \
    --http.vhosts '*' \
    --http.corsdomain '*' \
    --http.port 8545 \
    --http.api 'eth,net,web3,txpool,bor' \
    --syncmode 'full' \
    --networkid '137' \
    --mine \
    --miner.gaslimit '20000000' \
    --miner.gastarget '20000000' \
    --txpool.nolocals \
    --txpool.accountslots 16 \
    --txpool.globalslots 131072 \
    --txpool.accountqueue 64 \
    --txpool.globalqueue 131072 \
    --txpool.lifetime '1h30m0s' \
    --unlock $ADDRESS \
    --password $DATA_DIR/key.txt \
    --allow-insecure-unlock \
    --maxpeers 200 \
    --bor.heimdall 'http://restserver:1317' \
    --bootnodes "enode://0cb82b395094ee4a2915e9714894627de9ed8498fb881cec6db7c65e8b9a5bd7f2f25cc84e71e89d0947e51c76e85d0847de848c7782b13c0255247a6758178c@44.232.55.71:30303,enode://88116f4295f5a31538ae409e4d44ad40d22e44ee9342869e7d68bdec55b0f83c1530355ce8b41fbec0928a7d75a5745d528450d30aec92066ab6ba1ee351d710@159.203.9.164:30303"
