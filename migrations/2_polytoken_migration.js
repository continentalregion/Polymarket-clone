const gefy = artifacts.require("gefy");
// const gentrifees = artifacts.require("gentrifees");

module.exports = async function (deployer) {
  await deployer.deploy(gefy);
  const gefy = await gefy.deployed();
  console.log(`gefy.address`, gefy.address)
  // await deployer.deploy(gentrifees, gefy.address);
};
