// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {LibMarketValid} from "../lib/LibMarketValid.sol";

contract MarketFacet { /* is IAccessManaged */
    function setPrices(bytes calldata data) external restricted {}

    function execOrder(bytes calldata data) external restricted {
        (bytes32 orderKey, bool isOpen, bool isLong) = abi.decode(data, (bytes32, bool, bool));
        if (isOpen) {
            try IPositionAddMgrFacet.execOrderKey(orderKey) {
                // success
            } catch Error(string memory errorMessage) {
                bytes memory data = abi.encode(errorMessage);
                IOrderFacet.sysCancelOrder(data);
            }
        } else {
            try IPositionSubMgrFacet.execOrderKey(orderKey) {
                // success
            } catch Error(string memory errorMessage) {
                bytes memory data = abi.encode(errorMessage);
                IOrderFacet.sysCancelOrder(data);
            }
        }
    }

    //================================================================
    //   view functions
    //================================================================
    function isLiquidate(uint16 market, address account, bool isLong) external view {
        // LibMarketValid.validateLiquidation(market, pnl, fees, liquidateFee, collateral, size, raise);
    }

}
