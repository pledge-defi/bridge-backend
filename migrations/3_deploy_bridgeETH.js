const PledgerBridgeETH = artifacts.require("PledgerBridgeETH");

module.exports = function (deployer) {
  const mplgr_address = "0x550ea36E01Ada1d6dEd5fEfeA30E70aCA9275051";
  const bridge_address = "0x0C4DD68A014B58e0DDD590Bb014b0f7E71D2DaF4";
  const handler_address = "0x361F5886C42c631A241b1fE29f6BbfEf800B021f";
  const ddid = 0;
  const rid = "0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce10";

  deployer.deploy(PledgerBridgeETH, bridge_address, handler_address, mplgr_address, ddid, rid);
};
 