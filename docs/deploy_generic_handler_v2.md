说明：
```shell
chainbridge 1.1.5
cb-sol-cli 1.0.0
chainbridge-solidity 1.0.0

解决generic handler 版本不一致的问题。
```

BSC <> ETH

----

准备工作：

Source chain: BSC
Dest   chain: ETH(Ropsten)

PLGR 合约在 BSC 的地址： 【0x5a290631eC6BD34E9CfDC9B8084e3a1EEa5476B3】

---

第一步： Deploy contract on Source chain - BSC

准备：
1、设置【BSC】环境变量
0x8B8494cDAF423fAEB446F1a31697663eCA30690e
d355ce1b91b16a0fc6953cc20ec75e19060487a1a157679819d68595bc1e7ca3

```shell
SRC_GATEWAY=https://data-seed-prebsc-1-s1.binance.org:8545/
SRC_PK=d355ce1b91b16a0fc6953cc20ec75e19060487a1a157679819d68595bc1e7ca3
SRC_ADDR="0x2bAe5160A67FFE0d2dD9114c521dd51689FDB549","0x994354275A3512fc3C54543E1b400ea9dA1d3A0f","0xdfAE3230656b0AfBBdc5f4F16F49eEF9398fB51f"
```

2、部署命令
```shell (./index.js )
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 100000000000 deploy \
    --bridge --genericHandler \
    --relayers $SRC_ADDR \
    --relayerThreshold 3\
    --chainId 0
```

Output ===>

```shell

Deploying contracts...
✓ Bridge contract deployed
✓ GenericHandler contract deployed

================================================================
Url:        https://data-seed-prebsc-1-s1.binance.org:8545/
Deployer:   0x8B8494cDAF423fAEB446F1a31697663eCA30690e
Gas Limit:   8000000
Gas Price:   100000000000
Deploy Cost: 0.5661279

Options
=======
Chain Id:    0
Threshold:   3
Relayers:    0x2bAe5160A67FFE0d2dD9114c521dd51689FDB549,0x994354275A3512fc3C54543E1b400ea9dA1d3A0f,0xdfAE3230656b0AfBBdc5f4F16F49eEF9398fB51f
Bridge Fee:  0
Expiry:      100

Contract Addresses
================================================================
Bridge:             0xf1f5AC11743eBA290Cc08410860382C292E25c36
----------------------------------------------------------------
Erc20 Handler:      Not Deployed
----------------------------------------------------------------
Erc721 Handler:     Not Deployed
----------------------------------------------------------------
Generic Handler:    0x41A37498576Dd57A53342c5bf14Fe6A98f7eF8DE
----------------------------------------------------------------
Erc20:              Not Deployed
----------------------------------------------------------------
Erc721:             Not Deployed
----------------------------------------------------------------
Centrifuge Asset:   Not Deployed
----------------------------------------------------------------
WETC:               Not Deployed
================================================================


```

3、部署成功后，设置变量

```shell
SRC_BRIDGE="<resulting bridge contract address>"
SRC_HANDLER="<resulting erc20 handler contract address>"
```
SRC_BRIDGE=0xf1f5AC11743eBA290Cc08410860382C292E25c36
GENERIC_HANDLER_ADDRESS=0x41A37498576Dd57A53342c5bf14Fe6A98f7eF8DE


4、 在桥合约上注册 Token
The following registers the wFRA token as a resource with a bridge contract and configures which handler to use.

准备：
RESOURCE_ID=0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce00

注册命令：

SRC_GATEWAY=https://data-seed-prebsc-1-s1.binance.org:8545/
SRC_PK=d355ce1b91b16a0fc6953cc20ec75e19060487a1a157679819d68595bc1e7ca3
SRC_BRIDGE=0x0D52858bc128D056570e0E73C695eeC0bb3d7E04
GENERIC_HANDLER_ADDRESS=0x4E053d46122721b3Ec194b7248Cb4270c45e52eA
RESOURCE_ID=0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce00

// execute 			"deposit_mplgr_bridge(bytes)": "02c0ab3b",
```shell
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge register-generic-resource \
    --bridge $SRC_BRIDGE \
    --handler $GENERIC_HANDLER_ADDRESS \
    --resourceId $RESOURCE_ID \
    --execute 0x02c0ab3b \
    --targetContract 0xBEcFdD4600D11e2C4210E62ac04303FC84c1fa54 
```

第二步： Deploy contract on Dst chain - ETH(Ropsten)

1、部署准备
B-Ropsten
0x6e4f03a24CAec5D18fbA1c1eC78a5e1Ff6146028
0f6a853f71a5da0c4953de181283948f343e2f5e6471fbcd4e5d2606fa7af7fb

```shell
DST_GATEWAY=https://ropsten.infura.io/v3/acb534b53d3a47b09d7886064f8e51b6
DST_PK=0f6a853f71a5da0c4953de181283948f343e2f5e6471fbcd4e5d2606fa7af7fb
DST_ADDR="0x2bAe5160A67FFE0d2dD9114c521dd51689FDB549","0x994354275A3512fc3C54543E1b400ea9dA1d3A0f","0xdfAE3230656b0AfBBdc5f4F16F49eEF9398fB51f"
```


命令：
deploys the bridge contract, handler and a new ERC20 contract (mPLGR) on the destination chain.

```shell
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 deploy\
    --bridge --genericHandler \
    --relayers $SRC_ADDR \
    --relayerThreshold 3\
    --chainId 1
```

Output ===> 

```shell


Deploying contracts...
✓ Bridge contract deployed
✓ GenericHandler contract deployed

================================================================
Url:        https://ropsten.infura.io/v3/acb534b53d3a47b09d7886064f8e51b6
Deployer:   0x6e4f03a24CAec5D18fbA1c1eC78a5e1Ff6146028
Gas Limit:   8000000
Gas Price:   10000000000
Deploy Cost: 0.05695591

Options
=======
Chain Id:    1
Threshold:   3
Relayers:    0x2bAe5160A67FFE0d2dD9114c521dd51689FDB549,0x994354275A3512fc3C54543E1b400ea9dA1d3A0f,0xdfAE3230656b0AfBBdc5f4F16F49eEF9398fB51f
Bridge Fee:  0
Expiry:      100

Contract Addresses
================================================================
Bridge:             0x0291615D562af3106BBE6F4F49985ff0765FE0B5
----------------------------------------------------------------
Erc20 Handler:      Not Deployed
----------------------------------------------------------------
Erc721 Handler:     Not Deployed
----------------------------------------------------------------
Generic Handler:    0x3731BF4CA39D289E5078FCCaA89499BaDC12be49
----------------------------------------------------------------
Erc20:              Not Deployed
----------------------------------------------------------------
Erc721:             Not Deployed
----------------------------------------------------------------
Centrifuge Asset:   Not Deployed
----------------------------------------------------------------
WETC:               Not Deployed
================================================================

```

2、部署成功后，准备变量：
```shell
DST_BRIDGE="<resulting bridge contract address>"
DST_HANDLER="<resulting erc20 handler contract address>"
DST_TOKEN="<resulting erc20 token address>"
```
DST_BRIDGE=0x0291615D562af3106BBE6F4F49985ff0765FE0B5
DST_GENERIC_HANDLER=0x3731BF4CA39D289E5078FCCaA89499BaDC12be49
DST_GATEWAY=https://ropsten.infura.io/v3/acb534b53d3a47b09d7886064f8e51b6
DST_PK=0f6a853f71a5da0c4953de181283948f343e2f5e6471fbcd4e5d2606fa7af7fb

3、设置
The following registers the new token (mPLGR) as a resource on the bridge similar to the above.

```shell
cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 bridge register-generic-resource \
    --bridge $DST_BRIDGE \
    --handler $DST_GENERIC_HANDLER \
    --resourceId $RESOURCE_ID \
    --targetContract 0x496Eee2247fA366E2FF6E0E568eae698Efd9135c
```


第三步： 更新config 文件，启动 relayres

config0/1/2.json / config.json 四个文件中的 【bridge / generic_handler 地址！】

```shell
cd relayers
docker-compose up -d 
```

--------------------------------

第四步：测试


SRC_BRIDGE=0xf1f5AC11743eBA290Cc08410860382C292E25c36
GENERIC_HANDLER_ADDRESS=0x41A37498576Dd57A53342c5bf14Fe6A98f7eF8DE

DST_BRIDGE=0x0291615D562af3106BBE6F4F49985ff0765FE0B5
DST_GENERIC_HANDLER=0x3731BF4CA39D289E5078FCCaA89499BaDC12be49


======================================================



BSC:

PLGR: 0x1a91fa2c3c45fDA6d636D49e26Ce4889c07fd858
SRC_BRIDGE=0xf1f5AC11743eBA290Cc08410860382C292E25c36
GENERIC_HANDLER_ADDRESS=0x41A37498576Dd57A53342c5bf14Fe6A98f7eF8DE

PledgerBridgeBSC:
0xB6ED52d1f2690519364D623C4d5a049f953bfFa7

cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge register-generic-resource \
    --bridge $SRC_BRIDGE \
    --handler $GENERIC_HANDLER_ADDRESS \
    --resourceId $RESOURCE_ID \
    --execute 0x02c0ab3b \
    --targetContract 0xB6ED52d1f2690519364D623C4d5a049f953bfFa7 


ETH:

DST_BRIDGE=0x0291615D562af3106BBE6F4F49985ff0765FE0B5
DST_GENERIC_HANDLER=0x3731BF4CA39D289E5078FCCaA89499BaDC12be49

MPLGR:0xFc801C835A4Cf847eeAa903b0D838CCe3d81cA7c
RESOURCE_ID=0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce00

PledgerBridgeETH :
0xE0D8E8e5807334d8Fa0d3B060aA12dbf0a6b7B3d

cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 bridge register-generic-resource \
    --bridge $DST_BRIDGE \
    --handler $DST_GENERIC_HANDLER \
    --resourceId $RESOURCE_ID \
    --targetContract 0xE0D8E8e5807334d8Fa0d3B060aA12dbf0a6b7B3d

