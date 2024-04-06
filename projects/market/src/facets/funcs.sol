// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {IVault} from "../interfaces/IVault.sol";
import {MarketHandler} from "../lib/market/MarketHandler.sol";

function vault(uint16 market) view returns (IVault) {
    return IVault(MarketHandler.vault(market));
}
