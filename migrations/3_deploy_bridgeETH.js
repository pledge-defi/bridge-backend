const PledgerBridgeETH = artifacts.require("PledgerBridgeETH");

module.exports = function (deployer) {
  const mplgr_address = "0xb7d51b050f2072C2855B21579bB61955Cb484a97";
  const bridge_address = "0x909882A2a12157148331957baC08eDbc06C1f4F2";
  const handler_address = "0x3629cCFf769D3A29886fdE4be3777287AAF31337";
  const ddid = 0;
  const rid = "0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce10";

  deployer.deploy(PledgerBridgeETH, bridge_address, handler_address, mplgr_address, ddid, rid);
};
 