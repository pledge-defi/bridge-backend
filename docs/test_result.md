
RESOURCE_ID=0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce10


BSC:

PLGR: 0x1a91fa2c3c45fDA6d636D49e26Ce4889c07fd858
SRC_BRIDGE=0x0D52858bc128D056570e0E73C695eeC0bb3d7E04
GENERIC_HANDLER_ADDRESS=0x4E053d46122721b3Ec194b7248Cb4270c45e52eA


PledgerBridgeBSC:
0x277239573Ae3E996BB43743A37610D0a71E35B85

cb-sol-cli --url $SRC_GATEWAY --privateKey $SRC_PK --gasPrice 10000000000 bridge register-generic-resource \
    --bridge $SRC_BRIDGE \
    --handler $GENERIC_HANDLER_ADDRESS \
    --resourceId $RESOURCE_ID \
    --execute 0x02c0ab3b \
    --targetContract 0x277239573Ae3E996BB43743A37610D0a71E35B85 


ETH:

DST_BRIDGE=0x0C4DD68A014B58e0DDD590Bb014b0f7E71D2DaF4
DST_GENERIC_HANDLER=0x361F5886C42c631A241b1fE29f6BbfEf800B021f

MPLGR:0xFc801C835A4Cf847eeAa903b0D838CCe3d81cA7c

PledgerBridgeETH :
0xD8F4d3e7c8331d71f01199634012553a1337795A


cb-sol-cli --url $DST_GATEWAY --privateKey $DST_PK --gasPrice 10000000000 bridge register-generic-resource \
    --bridge $DST_BRIDGE \
    --handler $DST_GENERIC_HANDLER \
    --resourceId $RESOURCE_ID \
    --targetContract 0xD8F4d3e7c8331d71f01199634012553a1337795A


////////////////////////////////
BSC testnet:
https://testnet.bscscan.com/tx/0x06d0ed7157b37338d53e2bd15c1b679026b75a32c4e4b2eb2db1486aaaf1b247

ETH ropsten testnet:
https://ropsten.etherscan.io/address/0x0c4dd68a014b58e0ddd590bb014b0f7e71d2daf4


