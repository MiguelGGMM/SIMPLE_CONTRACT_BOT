
// Just an account with a lot of BNB
const bnbSender = `0x8894E0a0c962CB723c1976a4421c95949bE2D4E3`;

const WBNBmainnet = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
const BUSDmainnet = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
const WBNBtestnet = "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd";
const BUSDtestnet = "0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7";

const PANCAKESWAPmainnet = "0x10ED43C718714eb63d5aA57B78B54704E256024E";
const PANCAKESWAPtestnet = "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3";

const CABOT = artifacts.require("CABOT");
const BUSDContract = artifacts.require("IERC20");
const WBNBContract = artifacts.require("WBNB");

var cabot = null;
var busdCA = null;
var wbnbCA = null;

const debug = true;

const testMainnet = true;
const WBNB = testMainnet ? WBNBmainnet : WBNBtestnet;
const BUSD = testMainnet ? BUSDmainnet : BUSDtestnet;

/*
*   Util functions
*/

const toWei = (value) => web3.utils.toWei(value.toString());
const fromWei = (value, fixed=2) => parseFloat(web3.utils.fromWei(value)).toFixed(fixed);

const log = (message) => {
    if(debug){
        console.log(`[DEBUG] ${message}`);
    }
}

contract("CABOT", function (accounts) {

    /*
    *   CABOT tests
    */

    it("Should fail if a contract is not deployed", async function(){
        try {
            cabot = await CABOT.deployed();
            busdCA = await BUSDContract.at(BUSD);
            wbnbCA = await WBNBContract.at(WBNB);

            log(`Contracts deployed: CABOT, BUSDCA`);
            log(`Addresses: ${cabot.address}, ${busdCA.address}`);

            return assert.isTrue(true);
        } catch (err) {
            console.log(err.toString());
            return assert.isTrue(false);
        }
    });

    it("We perform a BUSD buy for different 4 accounts", async function(){
        try {
            const accountsTest = accounts.slice(4, 8);
            const buyAmount = toWei("0.01");
            log(`Buy amount: ${buyAmount.toString()} tokens, accounts: ${accountsTest.toString()}`);

            for(const element of accountsTest){
                // Get BNB from the big account unlocked
                // First buy WBNB...
                // Approve the WBNB spent by the contract first..
                log(`Account ${element}`);

                await web3.eth.sendTransaction({from: bnbSender, to: element, value: toWei(2)});
                await wbnbCA.deposit({ value: toWei(1), from: element }); 
                log(`Account ${element} balance: ${(await wbnbCA.balanceOf(element))}`);

                await wbnbCA.approve(cabot.address, toWei(1), { from: element });
                log(`Account ${element} spender approved: ${cabot.address}, amount: ${(await wbnbCA.allowance(element, cabot.address))}`);
            }     
                  
            log("Ready to perform buyBulk...");
            await cabot.buyBulk(0, Array(4).fill(buyAmount.toString()), [WBNB, BUSD], accountsTest, 10, 10);
            for(const element of accountsTest){
                const _busdBalance = await busdCA.balanceOf(element);
                log(`Address ${element} BUSD balance: ${fromWei(_busdBalance)}`);
            }
        } catch (err) {
            console.log(err.toString());
            return assert.isTrue(false);
        }
    });
});