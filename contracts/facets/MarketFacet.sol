// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {MarketHandler} from "../lib/market/MarketHandler.sol";
import {LibAccessManaged} from "../lib/ac/LibAccessManaged.sol";

contract MarketFacet { /* is IAccessManaged */
    function setPrices(bytes calldata data) external restricted {}

    function execOrder(bytes calldata data) external restricted {
        (bytes32 orderKey, bool isOpen, bool isLong) = abi.decode(data, (bytes32, bool, bool));
        if (isOpen) {
            try IPositionAddMgrFacet(address(this)).execAddOrderKey(orderKey) {
                // success
            } catch Error(string memory errorMessage) {
                bytes memory data = abi.encode(errorMessage);
                IOrderFacet.sysCancelOrder(data);
            }
        } else {
            try IPositionSubMgrFacet(address(this)).execSubOrderKey(orderKey) {
                // success
            } catch Error(string memory errorMessage) {
                bytes memory data = abi.encode(errorMessage);
                IOrderFacet.sysCancelOrder(data);
            }
        }
    }
}
