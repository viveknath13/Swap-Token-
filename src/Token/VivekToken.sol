// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract VivekToken is ERC20, Ownable {
    constructor() ERC20("Vivek", "vng") Ownable(msg.sender) {
        _mint(msg.sender, 10 * 10 ** decimals());
    }

    function mint(address _to, uint256 amount) public onlyOwner {
        _mint(_to, amount);
    }

    function getBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }
}
