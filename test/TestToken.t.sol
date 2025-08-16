// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {TokenSwap} from "../src/TokenSwap.sol";
import {VivekToken} from "../src/Token/VivekToken.sol";
import {BobToken} from "../src/Token/BobToken.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract TestToken is Test {
    TokenSwap tokenSwap;
    VivekToken public s_vivekToken;
    BobToken public s_bobToken;
    address public USER = makeAddr("user");

    function setUp() public {
        s_vivekToken = new VivekToken();
        s_bobToken = new BobToken();
        tokenSwap = new TokenSwap(address(s_vivekToken), address(s_bobToken));
        //mint the token and give it the user
        s_vivekToken.mint(USER, 3000 * 10 ** 18);
        s_bobToken.mint(USER, 3000 * 10 ** 18);
        vm.startPrank(USER);
        //type(uint256).max` is a convenient way to represent the largest possible number, which is like giving infinite approval for testing purposes).
        s_vivekToken.approve(address(tokenSwap), type(uint256).max);
        s_bobToken.approve(address(tokenSwap), type(uint256).max);
        vm.stopPrank();
    }

    function testAddLiquidity() public {
        //arrange

        uint256 amount = 100 * 10 ** 18;
        //Act
        vm.startPrank(USER);
        tokenSwap.addLiquidity(amount);
        vm.stopPrank();
        assertEq(tokenSwap.getBalance(USER), amount);
        assertEq(tokenSwap.getTotalAmount(), amount);
        assertEq(s_vivekToken.balanceOf(address(tokenSwap)), amount);
        assertEq(s_bobToken.balanceOf(address(tokenSwap)), amount);
    }

    function testRemoveLiquidity() public {
        uint256 initialBalance = 100 * 10 ** 18;

        vm.startPrank(USER);
        tokenSwap.addLiquidity(initialBalance);
        vm.stopPrank();
        uint256 removeToken = 50 * 10 ** 18;
        console.log(s_vivekToken.balanceOf(USER));
        console.log(s_bobToken.balanceOf(USER));
        vm.startPrank(USER);
        tokenSwap.removeLiquidity(removeToken);
        vm.stopPrank();

        assertEq(tokenSwap.getBalance(USER), initialBalance - removeToken);
        assertEq(tokenSwap.getTotalAmount(), initialBalance - removeToken);
        assertEq(
            s_vivekToken.balanceOf(address(tokenSwap)),
            initialBalance - removeToken
        );
        assertEq(
            s_bobToken.balanceOf(address(tokenSwap)),
            initialBalance - removeToken
        );
    }

    function testSwap() public {
        uint256 initialToken = 100 * 10 ** 18;

        vm.startPrank(USER);
        tokenSwap.addLiquidity(initialToken);
        vm.stopPrank();
        uint256 swapAmount = 10 * 10 ** 18;
        (uint256 reserveIn, uint256 reserveOut) = tokenSwap.getTokenBalances();
        uint256 expectAmountOut = (reserveOut * swapAmount) /
            (reserveIn + swapAmount);

        uint256 getInitialBobBalance = s_bobToken.balanceOf(USER);
        console.log(getInitialBobBalance);

        vm.startPrank(USER);
        tokenSwap.swap(address(s_vivekToken), swapAmount);
        vm.stopPrank();

        assertEq(
            s_bobToken.balanceOf(USER),
            getInitialBobBalance + expectAmountOut
        );
    }

    function testRemoveLiquidityRevert() public {
        uint256 initialToken = 100 * 10 ** 18;

        vm.startPrank(USER);
        tokenSwap.addLiquidity(initialToken);
        vm.stopPrank();
        uint256 removeToken = 150 * 10 ** 18;

        vm.expectRevert(TokenSwap.InsufficientAmount.selector);
        tokenSwap.removeLiquidity(removeToken);
    }

    function testFuzzAddLiquidity(uint256 amount) public {
        // Constrain the fuzzed amount to a reasonable upper bound to prevent overflow
        vm.assume(amount > 0 && amount < 100000 * 10 ** 18);

        // Mint the tokens needed for this specific test run
        s_vivekToken.mint(USER, amount);
        s_bobToken.mint(USER, amount);

        // Get initial balances to ensure the test is accurate
        uint256 initialUserLiquidity = tokenSwap.getBalance(USER);
        uint256 initialTotalLiquidity = tokenSwap.getTotalAmount();
        uint256 initialContractVivekBalance = s_vivekToken.balanceOf(
            address(tokenSwap)
        );
        uint256 initialContractBobBalance = s_bobToken.balanceOf(
            address(tokenSwap)
        );

        vm.startPrank(USER);
        tokenSwap.addLiquidity(amount);
        vm.stopPrank();

        // Assert that all balances are updated correctly
        assertEq(
            tokenSwap.getBalance(USER),
            initialUserLiquidity + amount,
            "User liquidity balance is incorrect"
        );
        assertEq(
            tokenSwap.getTotalAmount(),
            initialTotalLiquidity + amount,
            "Total liquidity is incorrect"
        );
        assertEq(
            s_vivekToken.balanceOf(address(tokenSwap)),
            initialContractVivekBalance + amount,
            "Contract VivekToken balance is incorrect"
        );
        assertEq(
            s_bobToken.balanceOf(address(tokenSwap)),
            initialContractBobBalance + amount,
            "Contract BobToken balance is incorrect"
        );
    }

    function testFuzzRemoveLiquidity(uint256 removeAmount) public {
        uint256 initialToken = 100 * 10 ** 18;
        s_vivekToken.mint(USER, initialToken);
        s_bobToken.mint(USER, initialToken);

        vm.startPrank(USER);
        tokenSwap.addLiquidity(initialToken);
        vm.stopPrank();

        vm.assume(removeAmount > 0 && removeAmount <= initialToken);

        // Capture the state BEFORE the action
        uint256 initialUserLiquidity = tokenSwap.getBalance(USER);
        uint256 initialTotalLiquidity = tokenSwap.getTotalAmount();
        uint256 initialContractVivekBalance = s_vivekToken.balanceOf(
            address(tokenSwap)
        );
        uint256 initialContractBobBalance = s_bobToken.balanceOf(
            address(tokenSwap)
        );
        uint256 initialUserVivekBalance = s_vivekToken.balanceOf(USER);
        uint256 initialUserBobBalance = s_bobToken.balanceOf(USER);

        vm.startPrank(USER);
        tokenSwap.removeLiquidity(removeAmount);
        vm.stopPrank();

        // Assert the state AFTER the action
        assertEq(
            tokenSwap.getBalance(USER),
            initialUserLiquidity - removeAmount
        );
        assertEq(
            tokenSwap.getTotalAmount(),
            initialTotalLiquidity - removeAmount
        );
        assertEq(
            s_vivekToken.balanceOf(address(tokenSwap)),
            initialContractVivekBalance - removeAmount
        );
        assertEq(
            s_bobToken.balanceOf(address(tokenSwap)),
            initialContractBobBalance - removeAmount
        );
        assertEq(
            s_vivekToken.balanceOf(USER),
            initialUserVivekBalance + removeAmount,
            "Vivek token amount is incorrect"
        );
        assertEq(
            s_bobToken.balanceOf(USER),
            initialUserBobBalance + removeAmount,
            "BOb token amount is incorrect"
        );
    }

function testFuzzSwap(uint256 swapAmount) public {
        uint256 initialLiquidity = 100 * 10 ** 18;
        
        // Constrain the swapAmount first to prevent overflow issues
        vm.assume(swapAmount > 0 && swapAmount < 100000 * 10 ** 18);
        
        // Provide the user with enough tokens for the initial liquidity.
        s_vivekToken.mint(USER, initialLiquidity);
        s_bobToken.mint(USER, initialLiquidity);
        
        // Add initial liquidity for the swap
        vm.startPrank(USER);
        tokenSwap.addLiquidity(initialLiquidity);
        vm.stopPrank();
        
        // Now mint the tokens needed for the swap
        s_vivekToken.mint(USER, swapAmount);
        
        // Calculate the expected output after all setup is complete
        (uint256 reserveIn, uint256 reserveOut) = tokenSwap.getTokenBalances();
        uint256 expectedAmountOut = (reserveOut * swapAmount) / (reserveIn + swapAmount);
        
        // Additional check to ensure expectedAmountOut is reasonable
        vm.assume(expectedAmountOut > 0 && expectedAmountOut <= reserveOut);
        
        // Capture the state before the swap
        uint256 initialUserVivekBalance = s_vivekToken.balanceOf(USER);
        uint256 initialUserBobBalance = s_bobToken.balanceOf(USER);
        uint256 initialContractVivekBalance = s_vivekToken.balanceOf(address(tokenSwap));
        uint256 initialContractBobBalance = s_bobToken.balanceOf(address(tokenSwap));
        
        // Perform the swap
        vm.startPrank(USER);
        tokenSwap.swap(address(s_vivekToken), swapAmount);
        vm.stopPrank();
        
        // Assert that all balances are updated correctly
        assertEq(s_vivekToken.balanceOf(USER), initialUserVivekBalance - swapAmount, "User VivekToken balance after swap is incorrect");
        assertEq(s_bobToken.balanceOf(USER), initialUserBobBalance + expectedAmountOut, "User BobToken balance after swap is incorrect");
        assertEq(s_vivekToken.balanceOf(address(tokenSwap)), initialContractVivekBalance + swapAmount, "Contract VivekToken balance after swap is incorrect");
        assertEq(s_bobToken.balanceOf(address(tokenSwap)), initialContractBobBalance - expectedAmountOut, "Contract BobToken balance after swap is incorrect");
    }

}
