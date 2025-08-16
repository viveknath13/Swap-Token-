// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {TokenSwap} from "../src/TokenSwap.sol";
import {VivekToken} from "../src/Token/VivekToken.sol";
import {BobToken} from "../src/Token/BobToken.sol";

contract DeployScript is Script {
    VivekToken vivektoken;
    BobToken bobtoken;
    TokenSwap tokenSwap;

    function run() public returns (VivekToken, BobToken, TokenSwap) {
        vm.startBroadcast();
        vivektoken = new VivekToken();
        bobtoken = new BobToken();
        tokenSwap = new TokenSwap(address(vivektoken), address(bobtoken));
        vm.stopBroadcast();
        console.log("The deployed address is ", address(tokenSwap));
        return (vivektoken, bobtoken, tokenSwap);
    }
}
