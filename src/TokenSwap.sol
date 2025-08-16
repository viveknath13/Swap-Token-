// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {VivekToken} from "./Token/VivekToken.sol";
import {BobToken} from "./Token/BobToken.sol";

contract TokenSwap {
    error InvalidToken();
    error InsufficientAmount();

    IERC20 public immutable VIVEK_TOKEN;
    IERC20 public immutable BOB_TOKEN;

    mapping(address => uint256) public s_balances;

    uint256 public s_TotalAmount;

    event AddLiquidity(address indexed token, uint256 amount);
    event RemoveLiquidity(address indexed token, uint256 amount);
    event SwappedToken(
        address indexed user, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut
    );

    constructor(address _VivekToken, address _BobToken) {
        if (_VivekToken == (address(0)) || _BobToken == address(0)) {
            revert InvalidToken();
        }

        VIVEK_TOKEN = IERC20(address(_VivekToken));
        BOB_TOKEN = IERC20(address(_BobToken));
    }

    function addLiquidity(uint256 _amount) public {
        require(_amount > 0, "Insufficient Token");
        s_balances[msg.sender] += _amount;
        s_TotalAmount += _amount;

        VIVEK_TOKEN.transferFrom(msg.sender, address(this), _amount);
        BOB_TOKEN.transferFrom(msg.sender, address(this), _amount);
        emit AddLiquidity(msg.sender, _amount);
    }

    function removeLiquidity(uint256 _amount) public {
        require(_amount > 0, "Insufficient Token");
        if (_amount > s_balances[msg.sender]) {
            revert InsufficientAmount();
        }

        s_balances[msg.sender] -= _amount;
        s_TotalAmount -= _amount;
        VIVEK_TOKEN.transfer(msg.sender, _amount);
        BOB_TOKEN.transfer(msg.sender, _amount);
        emit RemoveLiquidity(msg.sender, _amount);
    }

    function getTotalAmount() public view returns (uint256) {
        return s_TotalAmount;
    }

    function getBalance(address account) public view returns (uint256) {
        return s_balances[account];
    }

    function swap(address _token, uint256 amount) public {
        if (_token == address(0)) {
            revert InvalidToken();
        }
        require(amount > 0, "can't swap the zero token");
        IERC20 tokenIn = IERC20(_token);
        IERC20 tokenOut;

        if (tokenIn == VIVEK_TOKEN) {
            tokenOut = BOB_TOKEN;
        } else if (tokenIn == BOB_TOKEN) {
            tokenOut = VIVEK_TOKEN;
        } else {
            revert InvalidToken();
        }

        /**
         *
         *     core idea of this AMM is the formula x * y = k, where:
         * x is the reserve of the first token (e.g., reserveIn).
         * y is the reserve of the second token (e.g., reserveOut).
         * k is a constant value.
         *     Price ≈ `reserveOut / reserveIn
         *     `reserveOut` is in the numerator
         *     reserveIn is in the denominator
         */
        uint256 reserveIn = tokenIn.balanceOf(address(this));
        uint256 reserveOut = tokenOut.balanceOf(address(this));
        uint256 amountOut = (reserveOut * amount) / (reserveIn + amount);
        if (amountOut == 0) {
            revert InsufficientAmount();
        }

        tokenIn.transferFrom(msg.sender, address(this), amount);
        tokenOut.transfer(msg.sender, amountOut);
        emit SwappedToken(msg.sender, _token, address(tokenOut), amount, amountOut);
    }

    function getTokenBalances() public view returns (uint256, uint256) {
        return (VIVEK_TOKEN.balanceOf(address(this)), BOB_TOKEN.balanceOf(address(this)));
    }
}
