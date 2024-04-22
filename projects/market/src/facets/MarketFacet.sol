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
import {OrderFinder, OrderFinderCache} from "../lib/order/OrderFinder.sol";

import {GValidHandler} from "../lib/globalValid/GValidHandler.sol";

//================================================================
//interfaces
import {IAccessManaged} from "../ac/IAccessManaged.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IMarketFacet.sol";
import {IFeeFacet} from "../interfaces/IFeeFacet.sol";

contract MarketFacet is IAccessManaged, IMarketFacet {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableValues for EnumerableSet.AddressSet;
    using EnumerableValues for EnumerableSet.UintSet;

    using SafeERC20 for IERC20Metadata;

    event OracleAdded(
        uint16 market,
        address pricefeed,
        uint256 maxCumulativeDeltaDiffs
    );
    event MarketAdded(
        uint16 market,
        string name,
        address vault,
        address token,
        MarketHandler.Props config
    );

    //================================================================
    // only self
    //================================================================

    //================================================================
    // ADMIN
    //================================================================

    function setMarketConf(
        uint16 market,
        MarketHandler.Props memory data
    ) external restricted {
        // //TODO 查一下当前 market balance
        MarketHandler.Storage().config[market] = data;
        // test
    }

    function addMarket(
        string memory name,
        address _vault,
        uint256 maxMarketSizeLimit,
        MarketHandler.Props calldata config,
        bytes calldata oracle,
        bytes calldata fee
    ) external restricted returns (uint16 market) {
        market = MarketFacet(address(this)).SELF_addMarket(
            abi.encode(name, _vault, address(0), config)
        );
        MarketFacet(address(this)).SELF_addOracle(market, oracle);
        MarketFacet(address(this)).SELF_addGValid(market, maxMarketSizeLimit);
        IFeeFacet(address(this)).SELF_addFee(market, fee);
    }

    function SELF_addGValid(
        uint16 market,
        uint256 maxMarketSizeLimit
    ) external {
        if (address(this) != msg.sender) {
            _checkCanCall(msg.sender, msg.data);
        }
        GValidHandler.StorageStruct storage $ = GValidHandler.Storage();
        $.maxMarketSizeLimit[market] = maxMarketSizeLimit;
    }

    function SELF_addOracle(uint16 market, bytes calldata oracle) external {
        if (address(this) != msg.sender) {
            _checkCanCall(msg.sender, msg.data);
        }
        OracleHandler.StorageStruct storage $ = OracleHandler.Storage();
        (address pricefeed, uint256 maxCumulativeDeltaDiffs) = abi.decode(
            oracle,
            (address, uint256)
        );
        $.priceFeeds[market] = pricefeed;
        $.maxCumulativeDeltaDiffs[market] = maxCumulativeDeltaDiffs;
    }

    function SELF_addMarket(
        bytes calldata data
    ) external returns (uint16 market) {
        if (address(this) != msg.sender) {
            _checkCanCall(msg.sender, msg.data);
        }

        market = MarketHandler.Storage().marketIdAutoIncrease + 1;
        (
            string memory name,
            address _vault,
            address token,
            MarketHandler.Props memory config
        ) = abi.decode(data, (string, address, address, MarketHandler.Props));

        MarketHandler.Storage().name[market] = name;
        if (token == address(0)) {
            MarketHandler.Storage().token[market] = IERC4626(_vault).asset();
        } else {
            MarketHandler.Storage().token[market] = token;
        }
        bool suc = MarketHandler.Storage().marketIds[_vault].add(
            uint256(market)
        );
        require(suc, "MarketFacet: market already exists");
        MarketHandler.Storage().vault[market] = _vault;
        MarketHandler.Storage().config[market] = config;
        MarketHandler.Storage().marketIdAutoIncrease = market;
        emit MarketAdded(market, name, _vault, token, config);
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

    function markeConfig(
        uint16 market
    ) external view returns (MarketHandler.Props memory _config) {
        _config = MarketHandler.Storage().config[market];
    }

    function getGlobalPnl(address _vault) public view returns (int256) {
        EnumerableSet.UintSet storage marketIds = MarketHandler
            .Storage()
            .marketIds[_vault];
        uint256[] memory _markets = marketIds.values();
        int256 pnl = 0;
        for (uint256 i = 0; i < _markets.length; i++) {
            uint16 market = uint16(_markets[i]);
            pnl =
                pnl +
                PositionStorage.getMarketPNLInBoth(
                    market,
                    OracleHandler.getPrice(market, true),
                    OracleHandler.getPrice(market, false)
                );
        }
        return pnl;
    }

    function availableLiquidity(
        address market,
        address account,
        bool isLong
    ) external view returns (uint256) {
        // todo for front end
    }

    function getMarket(
        uint16 market
    ) external view returns (bytes memory result) {
        MarketHandler.StorageStruct storage $ = MarketHandler.Storage();
        return
            abi.encode(
                $.name[market],
                $.vault[market],
                $.token[market],
                $.balance[market],
                $.config[market]
            );
    }

    function getMarkets() external view returns (bytes memory result) {
        MarketHandler.StorageStruct storage $ = MarketHandler.Storage();
        uint256[] memory _markets = $.marketIds[msg.sender].values();
        bytes memory result = new bytes(_markets.length * 32);
        for (uint256 i = 0; i < _markets.length; i++) {
            uint16 market = uint16(_markets[i]);
            bytes memory data = abi.encode(
                $.name[market],
                $.vault[market],
                $.token[market],
                $.balance[market],
                $.config[market]
            );
            assembly {
                mstore(add(result, mul(i, 32)), data)
            }
        }
        return result;
    }

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

    function getExecutableOrdersByPrice(
        OrderFinderCache memory cache
    ) external view override returns (OrderProps[] memory _orders) {
        return OrderFinder.getExecutableOrdersByPrice(cache);
    }
}
