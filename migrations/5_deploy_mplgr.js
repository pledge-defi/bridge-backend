const MPLGR = artifacts.require("MPLGR");

module.exports = function (deployer) {
  const totalSupply = "100000000000000000000000000000";

  deployer.deploy(MPLGR, totalSupply);
};
 