// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IVault} from "../../interfaces/IVault.sol";

library BalanceHandler {
    using SafeERC20 for IERC20;

    bytes32 constant STORAGE_POSITION = keccak256("blex.balance.storage");

    enum Type {
        FeeToMarket,
        MarketToFee,
        MarketToUser,
        UserToMarket,
        MarketToVault,
        VaultToMarket,
        FeeToReward
    }

    struct StorageStruct {
        mapping(uint16 => uint256) feeBalance;
        mapping(uint16 => uint256) marketBalance;
    }

    event Transfer(
        uint16 indexed market, uint8 indexed transferType, address indexed account, uint256 value, bytes extra
    );

    function Storage() internal pure returns (StorageStruct storage fs) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    // DONE-----------
    function vaultToMarket(address vault, uint16 market, address account, uint256 value) internal {
        IVault(vault).withdrawFromVault(account, value);
        Storage().marketBalance[market] += value;
        emit Transfer(market, uint8(Type.VaultToMarket), account, value, bytes(""));
    }

    function marketToFee(uint16 market, address account, uint256 value) internal {
        Storage().marketBalance[market] -= value;
        Storage().feeBalance[market] += value;
        emit Transfer(market, uint8(Type.MarketToFee), account, value, bytes(""));
    }

    function feeToMarket(uint16 market, address account, int256[] memory fees, uint256 value) internal {
        // in case the balance is not enough, transfer the remaining balance
        uint256 _amount = Storage().feeBalance[market];
        if (value > _amount) value = _amount;

        Storage().feeBalance[market] -= value;
        Storage().marketBalance[market] += value;
        emit Transfer(market, uint8(Type.FeeToMarket), account, value, abi.encode(fees));
    }
    // TODO-------------

    function marketToVault(address vault, uint16 market, address account, uint256 value) internal {
        revert("TODO decimal convertion for pnl");
        Storage().marketBalance[market] -= value;
        emit Transfer(market, uint8(Type.MarketToVault), account, value, bytes(""));
    }

    function marketToUser(address token, uint16 market, address account, uint256 value) internal {
        Storage().marketBalance[market] -= value;
        IERC20(token).safeTransfer(account, value);
        emit Transfer(market, uint8(Type.MarketToUser), account, value, bytes(""));
    }

    function userToMarket(uint16 market, address account, uint256 value) internal {
        Storage().marketBalance[market] += value;
        emit Transfer(market, uint8(Type.UserToMarket), account, value, bytes(""));
    }

    function feeToReward(address token, uint16 market, address to, uint256 value) internal {
        Storage().feeBalance[market] -= value;
        IERC20(token).safeTransfer(to, value);
        emit Transfer(market, uint8(Type.FeeToReward), to, value, bytes(""));
    }
}
