try{
  const CABOT = artifacts.require("CABOT"); 

  const PANCAKESWAPmainnet = "0x10ED43C718714eb63d5aA57B78B54704E256024E";
  const PANCAKESWAPtestnet = "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3";

  //Migration
  const mainnet = true;

  console.log('Migrating');    

  module.exports = function(deployer) {
    if(mainnet){
        return deployer.deploy(CABOT, PANCAKESWAPmainnet);
    }else{
        return deployer.deploy(CABOT, PANCAKESWAPtestnet);
    }
  };

}catch(err){
  console.log(err.toString());
}
