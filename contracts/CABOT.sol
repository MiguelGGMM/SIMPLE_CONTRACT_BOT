// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Libraries/Ownable.sol";
import "./Libraries/IERC20.sol";
import "./Libraries/SafeMath.sol";
import "./Libraries/IPancakeRouter02.sol";

contract CABOT is Ownable {

    using SafeMath for uint256;

    IPancakeRouter02 routerIFACE;

    address router;
    uint256 honeyCheckAmountDiv = 1000; //x0.001

    constructor(address _router) { 
        router = _router;
        routerIFACE = IPancakeRouter02(_router);
    }    

    // Config
    function updateDEX(address _router) external onlyOwner {
        router = _router;
        routerIFACE = IPancakeRouter02(_router);
    }

    function withdrawToken(uint256 _amount, address _token) external onlyOwner { IERC20(_token).transfer(msg.sender, _amount); }

    function withdrawETH(uint256 _amount) external onlyOwner { payable(msg.sender).transfer(_amount); }
    ////////////////////////

    // Views
    function getAmountBuy(uint256 _amount) private view returns(uint256){ return _amount.sub(getAmountHoneyCheck(_amount)); }

    function getAmountHoneyCheck(uint256 _amount) private view returns(uint256){ return _amount.div(honeyCheckAmountDiv); }
    ////////////////////////

    // Swap and honey check
    function buyBulk(uint256 slip, uint256[] memory buyAmounts, address[] memory path, address[] memory accounts, uint8 maxBuyTax, uint8 maxSellTax) external onlyOwner {        
        IERC20(path[0]).transferFrom(accounts[0], address(this), getAmountHoneyCheck(buyAmounts[0]));        
        (uint8 taxBuy, uint8 taxSell) = honeypot(path, getAmountHoneyCheck(buyAmounts[0]));

        require (taxBuy <= maxBuyTax, 'High Buy Taxes');
        require (taxSell <= maxSellTax, 'High Sell Taxes');

        for (uint i = 0; i < accounts.length; i++){
            IERC20(path[0]).transferFrom(accounts[i], address(this), getAmountBuy(buyAmounts[i]));
            swap(slip, getAmountBuy(buyAmounts[i]), path, accounts[i]);
        }
    }

    function swap(uint256 slip, uint256 compra, address[] memory path, address to) internal {
        routerIFACE.swapExactTokensForTokensSupportingFeeOnTransferTokens
        (
            compra,
            slip,
            path, 
            to,
            block.timestamp + 120
        );
    }

    function honeypot(address[] memory path, uint256 honeyCheckAmount) internal returns (uint8, uint8) {        
        IERC20 tokenLiqIFACE = IERC20(path[0]);
        IERC20 tokenIFACE = IERC20(path[1]);

        if (tokenLiqIFACE.allowance(address(this), router) == 0){
            tokenLiqIFACE.approve(router, type(uint256).max);
        }
        if (tokenIFACE.allowance(address(this), router) == 0){
            tokenIFACE.approve(router, type(uint256).max);
        }

        uint256 balanceToken = tokenIFACE.balanceOf(address(this));
        uint256 expectedTokenBalance = routerIFACE.getAmountsOut(honeyCheckAmount, path)[1];
        routerIFACE.swapExactTokensForTokensSupportingFeeOnTransferTokens(honeyCheckAmount, 0, path, address(this), block.timestamp + 120);        

        balanceToken = tokenIFACE.balanceOf(address(this)) - balanceToken;
        require(balanceToken > 0, "No tokens received");

        uint256 taxBuy = (expectedTokenBalance.sub(balanceToken)).mul(100).div(expectedTokenBalance) + 1;

        address[] memory pathsell = new address[](2);
        pathsell[0] = path[1];
        pathsell[1] = path[0];

        uint256 tokenLiqBalance = tokenLiqIFACE.balanceOf(address(this));
        uint256 expectedTokenLiqBalance = routerIFACE.getAmountsOut(balanceToken, pathsell)[1];
        routerIFACE.swapExactTokensForTokensSupportingFeeOnTransferTokens(balanceToken, 0, pathsell, address(this), block.timestamp + 120);
        tokenLiqBalance = tokenLiqIFACE.balanceOf(address(this)) - tokenLiqBalance;
        uint256 taxSell = (expectedTokenLiqBalance.sub(tokenLiqBalance)).mul(100).div(expectedTokenLiqBalance) + 1;

        return (uint8(taxBuy), uint8(taxSell));
    }
    ////////////////////////

    receive() external payable { }
    fallback() external {}
}