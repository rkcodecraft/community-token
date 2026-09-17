// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {CommunityToken} from "../src/CommunityToken.sol";

contract DeployCommunityToken is Script {
    function run() external returns (CommunityToken) {
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        CommunityToken token = new CommunityToken();

        vm.stopBroadcast();

        return token;
    }
}