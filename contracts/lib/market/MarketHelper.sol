// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import {MarketPositionCallBackIntl, MarketOrderCallBackIntl, MarketCallBackIntl} from "./IMarketCallBackIntl.sol";
import {Order} from "../types/OrderStruct.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IVaultRouter} from "../../interfaces/vault/IVaultRouter.sol";

library MarketHelper {
    /**
     * @dev Withdraws profit and loss (PnL) from the vault.
     */
    function vaultWithdraw(address vr, uint16 market, address account, int256 pnl) internal {
        revert("TODO decimal convertion for pnl");
        if (pnl > 0) {
            IVaultRouter(vr).transferFromVault(account, uint256(pnl));
        }
    }

    /**
     * @dev Calculates the delta collateral for decreasing a position.
     * @return deltaCollateral The calculated delta collateral.
     */
    function getDecreaseDeltaCollateral(bool isKeepLev, uint256 size, uint256 dSize, uint256 collateral)
        internal
        pure
        returns (uint256 deltaCollateral)
    {
        if (isKeepLev) {
            deltaCollateral = (collateral * dSize) / size;
        } else {
            deltaCollateral = 0;
        }
    }

    /**
     * @dev Executes the necessary actions after updating a position.
     */
    function afterUpdatePosition(bytes calldata _item, uint16 market) internal {
        uint256 balanceBefore = IERC20(erc20Token).balanceOf(market);
        for (uint256 i = 0; i < plugins.length; i++) {
            if (MarketCallBackIntl(plugins[i]).getHooksCalls().updatePosition) {
                try MarketPositionCallBackIntl(plugins[i]).updatePositionCallback(_item) {} catch {}
            }
        }
        uint256 balanceAfter = IERC20(erc20Token).balanceOf(market);
        require(balanceAfter == balanceBefore, "ERC20 token balance changed");
    }

    /**
     * @dev Executes the necessary actions after updating an order.
     */
    function afterUpdateOrder(bytes calldata _item, uint16 market) internal {
        uint256 balanceBefore = IERC20(collateralToken).balanceOf(market);
        for (uint256 i = 0; i < plugins.length; i++) {
            if (MarketCallBackIntl(plugins[i]).getHooksCalls().updateOrder) {
                try MarketOrderCallBackIntl(plugins[i]).updateOrderCallback(_item) {} catch {}
            }
        }
        uint256 balanceAfter = IERC20(collateralToken).balanceOf(market);
        require(balanceAfter == balanceBefore, "ERC20 token balance changed");
    }

    /**
     * @dev Executes the necessary actions after deleting an order.
     */
    function afterDeleteOrder(bytes calldata _item, uint16 market) internal {
        uint256 balanceBefore = IERC20(erc20Token).balanceOf(market);
        for (uint256 i = 0; i < plugins.length; i++) {
            if (MarketCallBackIntl(plugins[i]).getHooksCalls().deleteOrder) {
                try MarketOrderCallBackIntl(plugins[i]).deleteOrderCallback(_item) {} catch {}
            }
        }
        uint256 balanceAfter = IERC20(erc20Token).balanceOf(market);
        require(balanceAfter == balanceBefore, "ERC20 token balance changed");
    }
}
