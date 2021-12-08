BSC <> ETH

----

准备工作：

Source chain: BSC
Dest   chain: ETH(Ropsten)

---

第一步： Deploy contract on Source chain - BSC

准备：
1、设置【BSC】环境变量
0x8B8494cDAF423fAEB446F1a31697663eCA30690e
d355ce1b91b16a0fc6953cc20ec75e19060487a1a157679819d68595bc1e7ca3

```shell
SRC_GATEWAY=https://data-seed-prebsc-1-s1.binance.org:8545/
SRC_PK=d355ce1b91b16a0fc6953cc20ec75e19060487a1a157679819d68595bc1e7ca3
SRC_ADDR="0xD984E4d1065C40680C653Db490ef6b15Ef4507e3","0x0CAF5A80492474A68459e9c049f5658f31Bf6019","0x21C6606F90E6065F654cd77171b26A21Ec57105c"
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
Relayers:    0xD984E4d1065C40680C653Db490ef6b15Ef4507e3,0x0CAF5A80492474A68459e9c049f5658f31Bf6019,0x21C6606F90E6065F654cd77171b26A21Ec57105c
Bridge Fee:  0
Expiry:      100

Contract Addresses
================================================================
Bridge:             0xFD97d7a42d93bFdEF9AB07A09C93c088c4a4eFf7
----------------------------------------------------------------
Erc20 Handler:      Not Deployed
----------------------------------------------------------------
Erc721 Handler:     Not Deployed
----------------------------------------------------------------
Generic Handler:    0x031E597dcE40406A0137DAedE70ea65e6fe0a2C2
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
SRC_BRIDGE=0xFD97d7a42d93bFdEF9AB07A09C93c088c4a4eFf7
GENERIC_HANDLER_ADDRESS=0x031E597dcE40406A0137DAedE70ea65e6fe0a2C2

RESOURCE_ID=0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce10

---

第二步： Deploy contract on Dst chain - ETH(Ropsten)

1、部署准备
B-Ropsten
0x6e4f03a24CAec5D18fbA1c1eC78a5e1Ff6146028
0f6a853f71a5da0c4953de181283948f343e2f5e6471fbcd4e5d2606fa7af7fb

eth-deploy
0xeBbA8791452310089D24DA37b64e57ab109D896e
b11b48b81c7a3ef0b259e81cdbb36b9d3d5c4e377cbec6dba03dd5e03425b7c9

```shell

DST_GATEWAY=https://ropsten.infura.io/v3/acb534b53d3a47b09d7886064f8e51b6
DST_PK=0f6a853f71a5da0c4953de181283948f343e2f5e6471fbcd4e5d2606fa7af7fb
DST_ADDR="0xD984E4d1065C40680C653Db490ef6b15Ef4507e3","0x0CAF5A80492474A68459e9c049f5658f31Bf6019","0x21C6606F90E6065F654cd77171b26A21Ec57105c"

```
2、部署命令
```shell

cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000  deploy \
    --bridge --genericHandler \
    --relayers $DST_ADDR \
    --relayerThreshold 3\
    --chainId 1


cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK deploy \
    --bridge \
    --genericHandler \
    --relayers $DST_ADDR \
    --relayerThreshold 3 \
    --chainId 1

rinkeby

rin-01
0x483CA0F80a42362B9dc4Cf712B29B9AF3597a86E
78b68c1a01041ba4605df80ef3e931a990a39e4068b9db097dbcb4e1f2de3f45

DST_GATEWAY=https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161
DST_PK=78b68c1a01041ba4605df80ef3e931a990a39e4068b9db097dbcb4e1f2de3f45

cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK deploy \
    --bridge \
    --genericHandler \
    --relayers $DST_ADDR \
    --relayerThreshold 3 \
    --chainId 1

cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000  deploy \
    --bridge --genericHandler \
    --relayers $DST_ADDR \
    --relayerThreshold 3\
    --chainId 1

```

Output ===>

```shell



```
