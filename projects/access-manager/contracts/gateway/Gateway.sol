// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {MulticallUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {MarketDataTypes} from "../interfaces/market/MarketDataTypes.sol";
import {IMarketReader} from "../interfaces/market/IMarketReader.sol";
import {IVaultReward} from "../interfaces/vault/IVaultReward.sol";
import "../utils/EnumerableValues.sol";

import {IMarketFactory} from "../interfaces/market/IMarketFactory.sol";
import {Position} from "../interfaces/position/PositionStruct.sol";
import {IMarketRouter} from "../interfaces/market/IMarketRouter.sol";
import {IMarketValid} from "../interfaces/market/IMarketValid.sol";
import {IPositionBook} from "../interfaces/position/IPositionBook.sol";
import {IMarket} from "../interfaces/market/IMarket.sol";
import {ICoreVault} from "../interfaces/vault/ICoreVault.sol";
import {IPrice} from "../interfaces/oracle/IPrice.sol";
import {IFundFee} from "../interfaces/fee/IFundFeeTest.sol";
import {IFeeRouter} from "../interfaces/fee/IFeeRouter.sol";
import {IERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

// 该合约实现以下几个合约的内容
// market router
// market reader
// fundfee
// vault reward
contract Gateway is AccessManagedUpgradeable, ReentrancyGuardUpgradeable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableValues for EnumerableSet.AddressSet;

    mapping(address => address) public marketRouters; // market => market router
    mapping(address => address) public fundFees; // market => fundfee
    mapping(address => address) public vaultRewards; // vault => vaultReward
    mapping(address => address) public marketReaders; // market => mreader
    EnumerableSet.AddressSet internal _vaultRewardSet;
    EnumerableSet.AddressSet internal _marketReaderSet;
    EnumerableSet.AddressSet internal _marketSet;
    EnumerableSet.AddressSet internal _vaultSet;

    function initialize(address initialAuthority) external initializer {
        __AccessManaged_init(initialAuthority);
    }

    function getVaultRewards() external view returns (address[] memory) {
        return _vaultRewardSet.values();
    }

    function addMarketReader(address market) external restricted {
        address marketReader = _getMarketReader(market);
        _getFundFee(market);
        _getMarketRouter(market);
        marketReaders[market] = marketReader;
        _marketReaderSet.add(marketReader);
    }

    /* function removeMarketReader(
        address market,
        address marketReader
    ) external restricted {
        delete marketReaders[market];
        _marketReaderSet.remove(marketReader);
    } */

    //========================================================================
    //                   market router
    //========================================================================

    function increasePosition(
        MarketDataTypes.UpdatePositionInputs memory _vars
    ) external nonReentrant {
        address marketRouter = _getMarketRouter(_vars._market);
        _vars._account = msg.sender;
        IMarketRouter(marketRouter).increasePosition(_vars);
    }

    function decreasePosition(
        MarketDataTypes.UpdatePositionInputs memory _vars
    ) external nonReentrant {
        address marketRouter = _getMarketRouter(_vars._market);
        _vars._account = msg.sender;
        IMarketRouter(marketRouter).decreasePosition(_vars);
    }

    function updateOrder(
        MarketDataTypes.UpdateOrderInputs memory _vars
    ) external nonReentrant {
        address marketRouter = _getMarketRouter(_vars._market);
        IMarketRouter(marketRouter).updateOrder(_vars);
    }

    function cancelOrderList(
        address[] memory _markets,
        bool[] memory _isIncreaseList,
        uint256[] memory _orderIDList,
        bool[] memory _isLongList
    ) external nonReentrant {
        require(
            _markets.length == _isIncreaseList.length &&
                _markets.length == _orderIDList.length &&
                _markets.length == _isLongList.length,
            "Array lengths do not match"
        );
        bool[] memory ppp = new bool[](1);
        uint256[] memory ppp2 = new uint256[](1);
        bool[] memory ppp3 = new bool[](1);

        for (uint256 index = 0; index < _markets.length; index++) {
            ppp[0] = _isIncreaseList[index];
            ppp2[0] = _orderIDList[index];
            ppp3[0] = _isLongList[index];
            IMarket(_markets[index]).cancelOrderList(
                msg.sender,
                ppp,
                ppp2,
                ppp3
            );
        }
    }

    //========================================================================
    //                   fund fee
    //========================================================================

    function getNextFundingRate(
        address market,
        uint256 longSize,
        uint256 shortSize
    ) external {
        address fundFee = _getFundFee(market);
        IFundFee(fundFee).getNextFundingRate(market, longSize, shortSize);
    }

    //========================================================================
    //                   vault reward
    //========================================================================

    /* function buy(
        IERC4626 vault,
        address to,
        uint256 amount,
        uint256 minSharesOut
    ) external nonReentrant returns (uint256 sharesOut) {
        address vaultReward = _getVaultRewards(address(vault));
        IVaultReward(vaultReward).buy(vault, to, amount, minSharesOut);
    }

    function sell(
        IERC4626 vault,
        address to,
        uint256 amount,
        uint256 minSharesOut
    ) external nonReentrant returns (uint256 sharesOut) {
        address vaultReward = _getVaultRewards(address(vault));
        IVaultReward(vaultReward).sell(vault, to, amount, minSharesOut);
    } */

    /* function claimLPReward(address[] memory vaults) external nonReentrant {
        for (uint256 index = 0; index < vaults.length; index++) {
            address vaultReward = _getVaultRewards(vaults[index]);
            IVaultReward(vaultReward).claimLPRewardForAccount(msg.sender);
        }
    } */

    /* function getLPReward() external view returns (bytes memory) {
        uint256[] memory rewards = new uint256[](_vaultSet.values().length);
        for (uint256 index = 0; index < _vaultSet.values().length; index++) {
            address v = _vaultSet.at(index);
            rewards[index] = IVaultReward(v).getLPReward(msg.sender);
        }
        return abi.encode(rewards, _vaultSet.values());
    }

    function getLPPrice() external view returns (bytes memory) {
        uint256[] memory prices = new uint256[](_vaultSet.values().length);
        for (uint256 index = 0; index < _vaultSet.values().length; index++) {
            address v = _vaultSet.at(index);
            prices[index] = IVaultReward(v).getLPPrice();
        }
        return abi.encode(prices, _vaultSet.values());
    } */

    //========================================================================
    //                   market reader
    //========================================================================
    function getMarkets()
        external
        view
        returns (IMarketFactory.Outs[] memory allMarkets)
    {
        uint256 len = _marketReaderSet.values().length;
        uint256 totalMarkets = 0;

        // 遍历所有的 market reader, 拼接之后返回
        for (uint256 index = 0; index < len; index++) {
            IMarketFactory.Outs[] memory marketsFromReader = IMarketReader(
                _marketReaderSet.at(index)
            ).getMarkets();
            uint256 marketsFromReaderLength = marketsFromReader.length;

            // 检查是否有足够的空间存储 marketsFromReader
            require(
                totalMarkets + marketsFromReaderLength <= 500,
                "markets>500"
            );

            // 将 marketsFromReader 拷贝到 allMarkets
            for (uint256 j = 0; j < marketsFromReaderLength; j++) {
                allMarkets[totalMarkets] = marketsFromReader[j];
                totalMarkets += 1;
            }
        }

        // 裁剪 allMarkets 数组，确保只返回实际填充的元素
        assembly {
            mstore(allMarkets, totalMarkets)
        }
    }

    function isLiquidate(
        address market,
        address account,
        bool isLong
    ) external view returns (uint256 _state) {
        return
            IMarketReader(marketReaders[market]).isLiquidate(
                market,
                account,
                isLong
            );
    }

    function getFundingRate(
        address market,
        bool isLong
    ) external view returns (int256, int256) {
        return
            IMarketReader(marketReaders[market]).getFundingRate(market, isLong);
    }

    function availableLiquidity(
        address market,
        address account,
        bool isLong
    ) external view returns (uint256) {
        return
            IMarketReader(marketReaders[market]).availableLiquidity(
                market,
                account,
                isLong
            );
    }

    function getMarket(
        address market
    )
        external
        view
        returns (
            IMarketReader.ValidOuts memory validOuts,
            IMarketReader.MarketOuts memory mktOuts,
            IMarketReader.FeeOuts memory feeOuts
        )
    {
        return IMarketReader(marketReaders[market]).getMarket(market);
    }

    function getPositions(
        address account,
        address market
    ) external view returns (Position.Props[] memory _positions) {
        return
            IMarketReader(marketReaders[market]).getPositions(account, market);
    }

    function getFundingFee(
        address account,
        address market,
        bool isLong
    ) external view returns (int256) {
        return
            IMarketReader(marketReaders[market]).getFundingFee(
                account,
                market,
                isLong
            );
    }

    //========================================================================
    //                   PRIVATE FUNC
    //========================================================================

    function _getFundFee(address market) private returns (address fundfee) {
        fundfee = fundFees[market];
        if (fundfee == address(0)) {
            // fundfee = market.feerouter.fundfee
            fundFees[market] = fundfee;
        }
    }

    function _getVaultRewards(
        address vault
    ) private returns (address vaultReward) {
        vaultReward = vaultRewards[vault];
        if (vaultReward == address(0)) {
            vaultReward = ICoreVault(vault).vaultReward();
            vaultRewards[vault] = vaultReward;
        }
    }

    function _getMarketRouter(
        address market
    ) private returns (address marketRouter) {
        marketRouter = marketRouters[market];
        if (marketRouter == address(0)) {
            // TODO
            // 从 market 里面读取 marketRouter 地址
            // 并且写入 marketRouter 状态变量中
            marketRouter = IMarket(market).marketRouter();
            marketRouters[market] = marketRouter;
            _marketSet.add(market);
        }
    }

    function _getMarketReader(
        address market
    ) private returns (address marketReader) {
        marketReader = marketReaders[market];
        if (marketReader == address(0)) {
            marketReader = IFundFee(IMarket(market).feeRouter().fundFee())
                .marketReader();
            marketReaders[market] = marketReader;
        }
    }
}
