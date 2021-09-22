const PaymentSplitter = artifacts.require("PaymentSplitter")

module.exports = async function (deployer, network, accounts) {
  // Deploy MyToken
  await deployer.deploy(PaymentSplitter)
  const splitter = await PaymentSplitter.deployed();

}