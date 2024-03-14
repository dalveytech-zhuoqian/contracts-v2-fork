// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {MarketHandler} from "../lib/market/MarketHandler.sol";
import {LibAccessManaged} from "../ac/LibAccessManaged.sol";
import {OracleHandler} from "../lib/oracle/OracleHandler.sol";

contract MarketFacet { /* is IAccessManaged */
    function setPricesAndExecute(bytes calldata _data) external stricted {
        (address token, uint256 price, uint256 timestamp, bytes[] memory _varList) =
            abi.decode(_data, (address, uint256, uint256, bytes[]));
        OracleHandler._setLastUpdatedValues(timestamp);
        OracleHandler._setPrice(token, price);

        for (uint256 index = 0; index < _varList.length; index++) {
            _execOrder(_varList[index]);
        }
    }

    function execOrder(bytes calldata data) external restricted {
        _execOrder(data);
    }

    function _execOrder(bytes calldata data) private {
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
