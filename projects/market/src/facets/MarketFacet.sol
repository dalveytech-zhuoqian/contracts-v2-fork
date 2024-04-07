// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../lib/utils/EnumerableValues.sol";
import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import "./funcs.sol";
//================================================================
//handlers
import {MarketHandler} from "../lib/market/MarketHandler.sol";
import {PositionStorage} from "../lib/position/PositionStorage.sol";
import {OracleHandler} from "../lib/oracle/OracleHandler.sol";

//================================================================
//interfaces
import {IAccessManaged} from "../ac/IAccessManaged.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MarketFacet is IAccessManaged {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableValues for EnumerableSet.AddressSet;
    using EnumerableValues for EnumerableSet.UintSet;

    using SafeERC20 for IERC20Metadata;

    //================================================================
    // only self
    //================================================================

    //================================================================
    // ADMIN
    //================================================================

    function setMarketConf(uint16 market, MarketHandler.Props memory data) external restricted {
        // //TODO 查一下当前 market balance
        MarketHandler.Storage().config[market] = data;
    }

    function addMarket(bytes calldata data) external restricted {
        (uint16 market, string memory name, address _vault, address token, MarketHandler.Props memory config) =
            abi.decode(data, (uint16, string, address, address, MarketHandler.Props));

        MarketHandler.Storage().name[market] = name;
        if (token == address(0)) {
            MarketHandler.Storage().token[market] = IERC4626(_vault).asset();
        } else {
            MarketHandler.Storage().token[market] = token;
        }
        bool suc = MarketHandler.Storage().marketIds[_vault].add(uint256(market));
        require(suc, "MarketFacet: market already exists");
        MarketHandler.Storage().vault[market] = _vault;
        MarketHandler.Storage().config[market] = MarketHandler.Props({
            isSuspended: false,
            allowOpen: true,
            allowClose: true,
            validDecrease: true,
            minSlippage: 0,
            maxSlippage: 100,
            minLeverage: 1,
            maxLeverage: 100,
            minPayment: 0,
            minCollateral: 0,
            decreaseNumLimit: 10,
            maxTradeAmount: 0
        });

        MarketHandler.Storage().config[market] = config;
    }

    function removeMarket(uint16 marketId) external restricted {
        MarketHandler.StorageStruct storage $ = MarketHandler.Storage();
        address _vault = $.vault[marketId];
        MarketHandler.Storage().marketIds[_vault].remove(uint256(marketId));
        delete MarketHandler.Storage().vault[marketId];
    }

    //================================================================
    // view only
    //================================================================
    function isLiquidate(uint16 market, address account, bool isLong) external view {
        // LibValidations.validateLiquidation(market, pnl, fees, liquidateFee, collateral, size, raise);
    }

    function markeConfig(uint16 market) external view returns (MarketHandler.Props memory _config) {
        _config = MarketHandler.Storage().config[market];
    }

    function getGlobalPnl(address _vault) public view returns (int256) {
        EnumerableSet.UintSet storage marketIds = MarketHandler.Storage().marketIds[_vault];
        uint256[] memory _markets = marketIds.values();
        int256 pnl = 0;
        for (uint256 i = 0; i < _markets.length; i++) {
            uint16 market = uint16(_markets[i]);
            pnl = pnl
                + PositionStorage.getMarketPNLInBoth(
                    market, OracleHandler.getPrice(market, true), OracleHandler.getPrice(market, false)
                );
        }
        return pnl;
    }

    function availableLiquidity(address market, address account, bool isLong) external view returns (uint256) {
        // todo for front end
    }

    function getMarket(uint16 market) external view returns (bytes memory result) {}

    function getMarkets() external view returns (bytes memory result) {}

    function getUSDDecimals() external pure returns (uint8) {
        return usdDecimals;
    }

    // function setPricesAndExecute(bytes calldata _data) external  {
    //     (uint16 market, uint256 price, uint256 timestamp, bytes[] memory _varList) =
    //         abi.decode(_data, (uint16, uint256, uint256, bytes[]));
    //     OracleHandler.setPrice(market, price);
    //     for (uint256 index = 0; index < _varList.length; index++) {
    //         // TODO
    //         // _execOrder(_varList[index]);
    //     }
    // }

    // function execOrder(bytes calldata data) external  {
    //     _execOrder(data);
    // }

    function containsMarket(uint16 marketId) external view returns (bool) {
        MarketHandler.StorageStruct storage $ = MarketHandler.Storage();
        address _vault = $.vault[marketId];
        return $.marketIds[_vault].contains(uint256(marketId));
    }

    // function _execOrder(bytes calldata data) private {
    //     // TODO...
    //     // (bytes32 orderKey, bool isOpen, bool isLong) = abi.decode(data, (bytes32, bool, bool));
    //     // if (isOpen) {
    //     //     try IPositionAddMgrFacet(address(this)).execAddOrderKey(orderKey) {
    //     //         // success
    //     //     } catch Error(string memory errorMessage) {
    //     //         bytes memory data = abi.encode(errorMessage);
    //     //         IOrderFacet.sysCancelOrder(data);
    //     //     }
    //     // } else {
    //     //     try IPositionSubMgrFacet(address(this)).execSubOrderKey(orderKey) {
    //     //         // success
    //     //     } catch Error(string memory errorMessage) {
    //     //         bytes memory data = abi.encode(errorMessage);
    //     //         IOrderFacet.sysCancelOrder(data);
    //     //     }
    //     // }
    // }
}
