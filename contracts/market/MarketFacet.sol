// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {LibMarketValid} from "../lib/LibMarketValid.sol";

contract MarketFacet { /* is IAccessManaged */
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

    function availableLiquidity(address market, address account, bool isLong) external view returns (uint256) {}

    function getMarket(uint16 market) external view returns (bytes memory result) {}

    function getMarketSizes(uint16 market) external view returns (uint256, uint256) {
        PositionStorage storage ps = LibPosition.Storage();
        return (
            ps.globalPositions[LibPosition.storageKey(market, true)].size,
            ps.globalPositions[LibPosition.storageKey(market, false)].size
        );
    }

    function getAccountSize(uint16 market, address account) external view returns (uint256, uint256) {
        PositionStorage storage ps = LibPosition.Storage();
        return (
            ps.positions[LibPosition.storageKey(market, true)][account].size,
            ps.positions[LibPosition.storageKey(market, false)][account].size
        );
    }

    function getPosition(uint16 market, address account, uint256 markPrice, bool isLong)
        external
        view
        returns (Position.Props memory)
    {
        PositionStorage storage ps = LibPosition.Storage();
        // TODO
        return ps.positions[LibPosition.storageKey(market, isLong)][account];
    }

    function getPositions(uint16 market, address account) external view returns (Position.Props[] memory) {
        PositionStorage storage ps = LibPosition.Storage();
        return ps.positions[LibPosition.storageKey(market, true)][account];
    }

    function getPositionKeys(uint16 market, uint256 start, uint256 end, bool isLong)
        external
        view
        returns (address[] memory)
    {
        PositionStorage storage ps = LibPosition.Storage();
        return ps.positionKeys[LibPosition.storageKey(market, isLong)].getRange(start, end);
    }

    function getPositionCount(uint16 market, bool isLong) external view returns (uint256) {
        PositionStorage storage ps = LibPosition.Storage();
        return ps.positionKeys[LibPosition.storageKey(market, isLong)].length();
    }

    function getPNL(uint16 market, address account, uint256 sizeDelta, uint256 markPrice, bool isLong)
        external
        view
        returns (int256)
    {}

    function getMarketPNL(uint16 market, uint256 longPrice, uint256 shortPrice) external view returns (int256) {}
    function globalSize() external view returns (uint256) {}

    function getGlobalPosition() external view returns (Position.Props memory) {}

    function get(address account) external view returns (Position.Props memory) {}

    function contains(address account) external view returns (bool) {}

    function getPositionCount() public view returns (uint256) {}

    function getPositionKeys(uint256 start, uint256 end) external view returns (address[] memory) {}
}
