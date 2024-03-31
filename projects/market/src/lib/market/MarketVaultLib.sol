// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IVault} from "../../interfaces/IVault.sol";
import {MarketHandler} from "./MarketHandler.sol";

library MarketVaultLib {
    using EnumerableSet for EnumerableSet.UintSet;

    function getGlobalOpenInterest(uint16 market) internal view returns (uint256) {
        MarketHandler.StorageStruct storage $ = MarketHandler.Storage();
        uint256 openInterest = 0;
        EnumerableSet.UintSet storage marketIds = $.marketIds[address(0)];
        address vault = $.vault[market];
        for (uint256 i = 0; i < marketIds.length(); i++) {
            uint16 marketId = uint16(marketIds.at(i));
            openInterest += IVault(vault).fundsUsed(marketId);
        }
        return openInterest;
    }

    function getAum(uint16 market) internal view returns (uint256) {
        MarketHandler.StorageStruct storage $ = MarketHandler.Storage();
        address vault = $.vault[market];
        return IVault(vault).getAUM();
    }
}
