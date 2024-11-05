// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/src/Test.sol";
import { TokenLaunchPad } from "../src/precision_loss/TokenLaunchPad.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";

contract example2 is Test {
    function setUp() public{
        MockERC20 _launchToken = new MockERC20("_launchToken", "_launchToken", 18);
        MockERC20 _stableCoin = new MockERC20("_stableCoin", "_stableCoin", 18);

        TokenLaunchPad pad = new TokenLaunchPad(_launchToken, _stableCoin);

    }

    function testFuzz_Precision_Loss_Accumulation_Bug(
        uint256 fixedPrivatePhasePrice, 
        uint256 perStableCoinAmountInPrivatePhase, 
        uint256 depositCountInPrivatePhase, 
        uint256 saleCap,
        uint256 perStableCoinAmountInPublicPhase, 
        uint256 depositCountInPublicPhase
    ) public {
        fixedPrivatePhasePrice = bound(fixedPrivatePhasePrice, 1e18 - 5e9, 1e18 + 5e9);
        perStableCoinAmountInPrivatePhase = bound(perStableCoinAmountInPrivatePhase, 1e18, 1e18 * 100);
        depositCountInPrivatePhase = bound(depositCountInPrivatePhase, 1, 10);


        /* private phase */
        uint256 alltokenAmount;
        uint256 privatePhaseAllocatedAmount;
        for(uint256 i = 0; i < depositCountInPrivatePhase; i++) {
            // calculate the record privatePhaseAllocatedAmount
            privatePhaseAllocatedAmount += pad.privateSale(perStableCoinAmountInPrivatePhase, fixedPrivatePhasePrice);
            alltokenAmount += perStableCoinAmountInPrivatePhase;
        }
        // calcualte the real claimed launch token in privatePhase
        uint256 realSumTokenAmountInPrivatePhase = pad.privateSale(alltokenAmount, fixedPrivatePhasePrice);
        console.log("privatePhaseAllocatedAmount", privatePhaseAllocatedAmount);
        console.log("realSumTokenAmountInPrivatePhase", realSumTokenAmountInPrivatePhase);
        console.log("diff", realSumTokenAmountInPrivatePhase - privatePhaseAllocatedAmount);



        /* public phase */
        saleCap = bound(saleCap, 1000e18, 2000e18);
        perStableCoinAmountInPublicPhase = bound(perStableCoinAmountInPublicPhase, 1e18, 1e18 * 100);  
        depositCountInPublicPhase = bound(depositCountInPublicPhase, 1 , 200);

        uint256 sumTokenDepositInPublic;
        for(uint256 i; i < depositCountInPublicPhase; i++) {
            sumTokenDepositInPublic += perStableCoinAmountInPublicPhase;
        }

        uint256 publicPhaseAllocatedAmount = saleCap - privatePhaseAllocatedAmount;
        uint256 dynamicPublicPhasePrice = pad.calculatePublicPhasePrice(publicPhaseAllocatedAmount, sumTokenDepositInPublic);
        uint256 dynamicPublicPhasePriceInReal = pad.calculatePublicPhasePrice(saleCap - realSumTokenAmountInPrivatePhase, sumTokenDepositInPublic);
        console.log("dynamicPublicPhasePrice", dynamicPublicPhasePrice);
        console.log("dynamicPublicPhasePriceInReal", dynamicPublicPhasePriceInReal);
        console.log("diff", dynamicPublicPhasePrice - dynamicPublicPhasePriceInReal);

        uint256 realSumTokenAmountInPublicPhase;
        for(uint256 i; i < depositCountInPublicPhase; i++) {
            realSumTokenAmountInPublicPhase += perStableCoinAmountInPublicPhase * dynamicPublicPhasePrice / DENOMINATOR;
        }

        /* claim phase */
        assertGe(saleCap - realSumTokenAmountInPrivatePhase, realSumTokenAmountInPublicPhase);

    }


}