// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {MarketHandler} from "../lib/market/MarketHandler.sol";
import {IAccessManaged} from "../ac/IAccessManaged.sol";
// import {OracleHandler} from "../lib/oracle/OracleHandler.sol";
import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IMarketInternal} from "../interfaces/IMarketInternal.sol";

contract MarketFacet is IAccessManaged, IMarketInternal {
    using EnumerableSet for EnumerableSet.UintSet;

    using SafeERC20 for IERC20;

    uint8 internal constant usdDecimals = 18; //数量精度

    function getUSDDecimals() external pure override returns (uint8) {
        return usdDecimals;
    }

    function formatCollateral(uint256 amount, uint8 collateralTokenDigits) public pure override returns (uint256) {
        return (amount * (10 ** uint256(collateralTokenDigits))) / (10 ** usdDecimals);
    }

    function parseVaultAsset(uint256 amount, uint8 originDigits) external pure override returns (uint256) {
        return (amount * (10 ** uint256(usdDecimals))) / (10 ** originDigits);
    }

    function parseVaultAssetSigned(int256 amount, uint8 collateralTokenDigits)
        external
        pure
        override
        returns (int256)
    {
        return (amount * int256(10 ** uint256(collateralTokenDigits))) / int256(10 ** uint256(usdDecimals));
    }

    function transferIn(address tokenAddress, address _from, address _to, uint256 _tokenAmount)
        external
        override
        onlySelf
    {
        // If the token amount is 0, return.
        if (_tokenAmount == 0) return;
        // Retrieve the token contract.
        IERC20 coll = IERC20(tokenAddress);
        // Format the collateral amount based on the token's decimals and transfer the tokens.
        coll.safeTransferFrom(_from, _to, formatCollateral(_tokenAmount, IERC20Metadata(tokenAddress).decimals()));
    }

    function transferOut(address tokenAddress, address _to, uint256 _tokenAmount) external override onlySelf {
        // If the token amount is 0, return.
        if (_tokenAmount == 0) return;
        // Retrieve the token contract.
        IERC20 coll = IERC20(tokenAddress);
        // Format the collateral amount based on the token's decimals.
        _tokenAmount = formatCollateral(_tokenAmount, IERC20Metadata(tokenAddress).decimals());
        // Transfer the tokens to the specified address.
        coll.safeTransfer(_to, _tokenAmount);
    }

    function setConf(uint16 market, MarketHandler.Props memory data) external restricted {
        // //TODO 查一下当前 market balance
        MarketHandler.Storage().config[market] = data;
    }

    function addMarket(bytes calldata data) external restricted {
        (uint16 market, string memory name, address vault, address token, MarketHandler.Props memory config) =
            abi.decode(data, (uint16, string, address, address, MarketHandler.Props));

        MarketHandler.Storage().name[market] = name;
        if (token == address(0)) {
            MarketHandler.Storage().token[market] = IERC4626(vault).asset();
        } else {
            MarketHandler.Storage().token[market] = token;
        }
        MarketHandler.Storage().marketIds[vault].add(uint256(market));
        MarketHandler.Storage().vault[market] = vault;
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
        address vault = $.vault[marketId];
        MarketHandler.Storage().marketIds[vault].remove(uint256(marketId));
        delete MarketHandler.Storage().vault[marketId];
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
        address vault = $.vault[marketId];
        return $.marketIds[vault].contains(uint256(marketId));
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
