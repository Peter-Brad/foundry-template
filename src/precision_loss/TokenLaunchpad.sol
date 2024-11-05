// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function withdraw(uint256 wad) external;
    function deposit(uint256 wad) external returns (bool);
    function owner() external view returns (address);
}


contract TokenLaunchPad{

    IERC20 launchToken;
    IERC20 stableCoin;

    uint256 fixedPrivatePhasePrice;
    uint256 dynamicPublicPhasePrice;
    uint256 DENOMINATOR = 1e18;

    uint256 saleCap = 100 * 1e18;
    uint256 privatePhaseAllocatedAmount;
    uint256 publicPhaseAllocatedAmount;

    mapping(address => uint256) public userPrivateDepositAmount;
    mapping(address => uint256) public userPublicDepositAmount;
    uint256 public totalPublicDepositAmount;

    constructor(IERC20 _launchToken, IERC20 _stableCoin){
        launchToken = _launchToken;
        stableCoin = _stableCoin;
    }

    function privateSale(uint256 stableCoinAmount) public {
        stableCoin.transferFrom(msg.sender, address(this), stableCoinAmount);
        uint256 launchTokenAmount = 
        stableCoinAmount * fixedPrivatePhasePrice / DENOMINATOR;
        
        userPrivateDepositAmount[msg.sender] += stableCoinAmount;
        privatePhaseAllocatedAmount += launchTokenAmount;
        publicPhaseAllocatedAmount = saleCap - privatePhaseAllocatedAmount;
    }

    function publicSale(uint256 stableCoinAmount) public {
        stableCoin.transferFrom(msg.sender, address(this), stableCoinAmount);
        userPublicDepositAmount[msg.sender] += stableCoinAmount;
        totalPublicDepositAmount += stableCoinAmount;
        calculatePublicPhasePrice();
    }

    function calculatePublicPhasePrice() public returns (uint256){
        dynamicPublicPhasePrice = 
        publicPhaseAllocatedAmount * DENOMINATOR / totalPublicDepositAmount;

        return dynamicPublicPhasePrice;
    }

    function userClaimLaunchToken() public {
        uint256 launchTokenAmount = 
        userPublicDepositAmount[msg.sender] * dynamicPublicPhasePrice / DENOMINATOR;
        launchTokenAmount += 
        userPrivateDepositAmount[msg.sender] * fixedPrivatePhasePrice / DENOMINATOR;
        
        userPublicDepositAmount[msg.sender] = 0;
        userPrivateDepositAmount[msg.sender] = 0;
        launchToken.transfer(msg.sender, launchTokenAmount);
    }

}



