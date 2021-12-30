const PledgerBridgeBSC = artifacts.require("PledgerBridgeBSC");

module.exports = function (deployer) {
  const plgr_address = "0x22E6f32805d2AC7F787ca72b2F0bdbCE1693573b";
  const bridge_address = "0x0D52858bc128D056570e0E73C695eeC0bb3d7E04";
  const handler_address = "0x4E053d46122721b3Ec194b7248Cb4270c45e52eA";
  const ddid = 1;
  const rid = "0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce10";

  deployer.deploy(PledgerBridgeBSC, plgr_address, bridge_address, handler_address, ddid, rid);
};
 