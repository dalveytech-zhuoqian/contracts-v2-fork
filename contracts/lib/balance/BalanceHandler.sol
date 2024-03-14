// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// import {FeeType} from "../types/FeeType.sol";
// import {MarketDataTypes} from "../types/MarketDataTypes.sol";

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

    function marketToFee(uint16 market, address account, uint256 value) internal {
        Storage().marketBalance[market] -= value;
        Storage().feeBalance[market] += value;
        emit Transfer(market, uint8(Type.MarketToFee), account, value, bytes(""));
    }

    function marketToVault(uint16 market, address account, uint256 value) internal {
        Storage().marketBalance[market] -= value;
        emit Transfer(market, uint8(Type.MarketToVault), account, value, bytes(""));
    }

    function marketToUser(uint16 market, address account, uint256 value) internal {
        address token;
        Storage().marketBalance[market] -= value;
        IERC20(token).safeTransfer(account, value);
        emit Transfer(market, uint8(Type.MarketToUser), account, value, bytes(""));
    }

    function feeToMarket(uint16 market, address account, int256[] memory fees, uint256 value) internal {
        uint256 _amount = Storage().feeBalance[market];
        if (_amount > value) _amount = value;
        Storage().feeBalance[market] += _amount;
        Storage().marketBalance[market] -= _amount;
        emit Transfer(market, uint8(Type.FeeToMarket), account, _amount, abi.encode(fees));
    }

    function userToMarket(uint16 market, address account, uint256 value) internal {
        Storage().marketBalance[market] += value;
        emit Transfer(market, uint8(Type.UserToMarket), account, value, bytes(""));
    }

    function feeToReward(uint16 market, address to, uint256 value) internal {
        address token;
        Storage().feeBalance[market] -= value;
        IERC20(token).safeTransfer(to, value);
        emit Transfer(market, uint8(Type.FeeToReward), to, value, bytes(""));
    }
}
