BSC -> ETH
正向流程测试】】】

remixd -s . -u https://remix.ethereum.org/

第零步： 注册 targetContract （PledgerBridgeETH 合约地址） / execute (ETH deposit_mplgr_bridge 方法)

PledgerBridgeBSC:
0xd9145CCE52D386f254917e481eB44e9943F39138

SRC_BRIDGE=0x0D52858bc128D056570e0E73C695eeC0bb3d7E04
GENERIC_HANDLER_ADDRESS=0x4E053d46122721b3Ec194b7248Cb4270c45e52eA
RESOURCE_ID=0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce10
SRC_GATEWAY=https://data-seed-prebsc-1-s1.binance.org:8545/
SRC_PK=d355ce1b91b16a0fc6953cc20ec75e19060487a1a157679819d68595bc1e7ca3

PledgerBridgeETH :
0x77060B1a016E74b139fa2C34B5d887fD7ddCb47c

// targetContract -> PledgerBridgeETH
// execute -> deposit_mplgr_bridge()

cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge register-generic-resource \
    --bridge $SRC_BRIDGE \
    --handler $GENERIC_HANDLER_ADDRESS \
    --resourceId $RESOURCE_ID \
    --execute 0x02c0ab3b \
    --targetContract 0x77060B1a016E74b139fa2C34B5d887fD7ddCb47c 



第一步： plgr 合约 approve 给 PledgerBridgeBSC合约 address
approve -> PledgerBridgeBSC address

第二步
start web3 script

第三步
PledgerBridgeBSC合约 调用 deposit_plgr方法 -> current account

---




relayer 0/1/2
0x2bAe5160A67FFE0d2dD9114c521dd51689FDB549
0x994354275A3512fc3C54543E1b400ea9dA1d3A0f
0xdfAE3230656b0AfBBdc5f4F16F49eEF9398fB51f

替换 relayers ===>

relayer01:
0xD984E4d1065C40680C653Db490ef6b15Ef4507e3
4e727300b5ef1ed4070e88b58ae2d488dab6b4d65f049932c7ebb9b4be7fa4a9

relayer02:
0x0CAF5A80492474A68459e9c049f5658f31Bf6019
cebd43099b6ee41c0afe5fc5a84444dd25fe678ba84766785c91a196071915dc

relayer03:
0x21C6606F90E6065F654cd77171b26A21Ec57105c
0100ec845781bdc9ce455028e25082a718630932b9c7ee4baaf484ef1dc15703


2、替换 relayer 文件的配置信息
3、