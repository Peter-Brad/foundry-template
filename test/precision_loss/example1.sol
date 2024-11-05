// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/src/Test.sol";

contract contractExample is Test {

    function setUp() public{

    }

    function test_Precision_Loss_Accumulation_Bug() external {
        uint256 a = 10;
        uint256 b = 11;
        uint256 c = 12;

        uint256 result_1 = a / c + b / c;   // 0
        uint256 result_2 = (a + b) / c;   //1

        console.log( "result_1: ",result_1 );
        console.log( "result_2: ",result_2 );   
        assertEq(result_1, result_2);   
    }

    function test_round_error() external{
        uint256 a = 150;
        uint256 b = 100;
        uint256 c= 11;

        uint256 result_1 = (a*c)/b; 

        console.log( "result: ",result_1 );  //16,not 16.50
    }

    

}