// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {MarketHandler} from "../lib/market/MarketHandler.sol";
import {IAccessManaged} from "../ac/IAccessManaged.sol";
import {OracleHandler} from "../lib/oracle/OracleHandler.sol";

contract MarketFacet is IAccessManaged {
    function addMarket(uint16 marketId, address vault) external restricted {
        MarketHandler.addMarket(marketId, vault);
    }

    function removeMarket(uint16 marketId) external {
        MarketHandler.removeMarket(marketId);
    }

    function setPricesAndExecute(bytes calldata _data) external restricted {
        (uint16 market, uint256 price, uint256 timestamp, bytes[] memory _varList) =
            abi.decode(_data, (uint16, uint256, uint256, bytes[]));
        OracleHandler.setPrice(market, price);
        for (uint256 index = 0; index < _varList.length; index++) {
            // TODO
            // _execOrder(_varList[index]);
        }
    }

    function execOrder(bytes calldata data) external restricted {
        _execOrder(data);
    }

    function containsMarket(uint16 marketId) external view returns (bool) {
        return MarketHandler.containsMarket(marketId);
    }

    function _execOrder(bytes calldata data) private {
        // TODO...
        // (bytes32 orderKey, bool isOpen, bool isLong) = abi.decode(data, (bytes32, bool, bool));
        // if (isOpen) {
        //     try IPositionAddMgrFacet(address(this)).execAddOrderKey(orderKey) {
        //         // success
        //     } catch Error(string memory errorMessage) {
        //         bytes memory data = abi.encode(errorMessage);
        //         IOrderFacet.sysCancelOrder(data);
        //     }
        // } else {
        //     try IPositionSubMgrFacet(address(this)).execSubOrderKey(orderKey) {
        //         // success
        //     } catch Error(string memory errorMessage) {
        //         bytes memory data = abi.encode(errorMessage);
        //         IOrderFacet.sysCancelOrder(data);
        //     }
        // }
    }
}
