const gentrifees = artifacts.require("gefy");

module.exports = async function (deployer) {
  await deployer.deploy(
    gentrifees,
    "0x8ecd3463bea3eC99B3BBf81cd8502D84E5A60179"
  );
};
