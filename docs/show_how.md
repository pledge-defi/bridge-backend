BSC => ETH 及 ETH => BSC 的演示步骤

----------------------BSC ===>>> ETH----------------------
第0步、
1）使用 remix 链接本地代码
```shell
remixd -s . -u https://remix.ethereum.org/
```
2）打开 relayer0 的日志
```shell
docker logs --tail 10 -f relayer0
```
3）打开 开发机 第二个窗口、relayers 目录下执行 
```shell
source ./chainbridge-vars
```

第1步、切换到 BSC testnet，选择账号 UserAccount 0x8B8494cDAF423fAEB446F1a31697663eCA30690e

第2步、选择合约代码，At 出来的合约包括：
1）plgr contract address : 
0x1a91fa2c3c45fDA6d636D49e26Ce4889c07fd858

2）PledgerBridgeBSC contract address : 
0x277239573Ae3E996BB43743A37610D0a71E35B85

3）PledgerBridgeETH contract address ：(需要切换网络到 reposten)
0xD8F4d3e7c8331d71f01199634012553a1337795A

第3步、
在plgr合约进行approve给PledgerBridgeBSC合约操作；
进入PledgerBridgeBSC合约，执行 deposit_plgr 方法； 0x8B8494cDAF423fAEB446F1a31697663eCA30690e 、 100000

第4步、（keeper service）暂时手动调用
1）执行 check_keep，得到 deposit 的index；
2）index 作为参数，执行 execute_keep 方法。
3）查看 execute_keep 交易 hash，去 BSC testnet 查看交易情况
```shell
https://testnet.bscscan.com/tx/使用新的hash替换
```
4）查看 relayer 后台监听情况，大概 vote 成功后的 10-blocks，查看 ETH testnet 上 chainbridgeETH 合约的 txn
```shell
https://ropsten.etherscan.io/address/0x0c4dd68a014b58e0ddd590bb014b0f7e71d2daf4
```

第5步、上述成功后，进入到 PledgerBridgeETh : 0xD8F4d3e7c8331d71f01199634012553a1337795A 合约的 mplgr_amounts 方法 查看 UserAccount 余额。

第6步、调用 widthdraw_mplgr 方法，提取到 UserAccount 。

plgr 从 BSC 垮桥到 ETH 的 mplgr 流程完成。


----

----------------------ETH ===>>> BSC----------------------

第0步、切换到 ropsten 网络，
1）选择 UserAccountETH (ETH) 0x6e4f03a24CAec5D18fbA1c1eC78a5e1Ff6146028
2）注册 PledgerBridgeBSC 0x277239573Ae3E996BB43743A37610D0a71E35B85 到 relayer 网络
```shell
cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge register-generic-resource \
    --bridge $SRC_BRIDGE \
    --handler $GENERIC_HANDLER_ADDRESS \
    --resourceId $RESOURCE_ID \
    --execute 0x02c0ab3b \
    --targetContract 0x277239573Ae3E996BB43743A37610D0a71E35B85 
```

第1步、
1）选择 MPLGR 合约，At 出来
contract address: 0xFc801C835A4Cf847eeAa903b0D838CCe3d81cA7c 

2）在 MPLGR 合约，UserAccountETH approve PledgerBridgeETH 0xD8F4d3e7c8331d71f01199634012553a1337795A 。
3）PledgerBridgeETH 合约，调用 deposit_mplgr
4）去 ETH testnet 查看交易情况
```shell
https://ropsten.etherscan.io/tx/0xd30f056915659ae4a5ad25531f196c153d8e7b239e116857aeb9a9fd2fd14bbb
```

第2步、查看 relayer 后台监听情况，大概 vote 成功后的 10-blocks，查看 BSC testnet 上 chainbridgeBSC 合约的 txn
```shell
https://testnet.bscscan.com/address/0x0d52858bc128d056570e0e73c695eec0bb3d7e04
```

第5步、上述成功后，进入到 PledgerBridgeBSC : 0x277239573Ae3E996BB43743A37610D0a71E35B85 合约的 plgr_amounts 方法 查看 UserAccount plgr余额。

第6步、调用 widthdraw_plgr 方法，提取 。

mplgr 从 ETH 垮桥到 BSC 的 plgr 流程完成。

