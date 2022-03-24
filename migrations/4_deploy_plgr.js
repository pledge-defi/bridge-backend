const PLGR = artifacts.require("PLGR");

module.exports = function (deployer) {
  const totalSupply = "100000000000";

  deployer.deploy(PLGR, totalSupply);
};
 