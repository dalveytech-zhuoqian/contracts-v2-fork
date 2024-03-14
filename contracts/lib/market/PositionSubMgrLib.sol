// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;

import {Position} from "../types/PositionStruct.sol";
import {MarketDataTypes} from "../types/MarketDataTypes.sol";
import {FeeType} from "../types/FeeType.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";

library PositionSubMgrLib {
    using SafeCast for int256;
    using SafeCast for uint256;
    using MarketDataTypes for int256[];

    error TotalFeesLtZero();

    /**
     * @param _originFees 原始应当收取的费用数据
     * @return withdrawFromFeeVault 应该提取到 market 的费用总数
     * @return afterFees 按照费用优先级, 在考虑盈亏数据之后, 返回的真实费用数组
     */
    function calculateWithdrawFromFeeVault(int256[] memory _originFees)
        internal
        pure
        returns (int256 withdrawFromFeeVault, int256[] memory afterFees)
    {
        int256 fundFee = _originFees[uint8(FeeType.T.FundFee)];
        if (fundFee >= 0) return (0, _originFees);
        afterFees = new int256[](_originFees.length);
        for (uint256 i = 0; i < _originFees.length; i++) {
            afterFees[i] = _originFees[i];
        }
        afterFees[uint8(FeeType.T.FundFee)] = 0;
        return (-fundFee, afterFees);
    }

    /**
     *
     * @param _position 用户仓位
     * @param dPNL 盈亏
     * @param fees 原始费用数据
     */
    function calculateTransToFeeVault(
        Position.Props memory _position, // 仓位属性
        int256 dPNL, // 盈亏
        int256 fees // 手续费
    ) internal pure returns (int256 transferToFeeVaultAmount) {
        int256 remain = _position.collateral.toInt256() + dPNL; // 计算剩余金额
        if (fees < 0) revert TotalFeesLtZero(); // 如果手续费小于0，则抛出异常
        if (remain > 0) return SignedMath.min(remain, fees); // 如果剩余金额大于0，则返回剩余金额和手续费中较小的一个
            // 默认返回 0
    }

    function calculateTransToVault(int256 collateral, int256 dPNL) internal pure returns (int256) {
        return collateral + dPNL <= 0 ? collateral : -dPNL;
    }

    function calculateTransToUser(
        MarketDataTypes.Cache memory _params, // 定义更新仓位所需的参数
        Position.Props memory _position, // 定义当前仓位的属性
        int256 dPNL, // 变动盈亏
        int256 fees // 手续费
    ) internal pure returns (int256) {
        // 检查是否完全平仓
        bool isCloseAll = _position.size == _params.sizeDelta;
        // 如果完全平仓，更新参数中的保证金变动
        if (isCloseAll) _params.collateralDelta = _position.collateral;
        // 如果保证金不足以支付亏损和手续费，则触发清算，返回0
        if (_position.collateral.toInt256() + dPNL - fees <= 0) return 0;
        // 如果保证金变动后能够保持杠杆或增仓
        if (_params.collateralDelta.toInt256() + dPNL - fees > 0) {
            return _params.collateralDelta.toInt256() + dPNL - fees;
        }
        // 包含不保持杠杆减仓的情况，返回0
        if (_params.collateralDelta.toInt256() + dPNL - fees <= 0) return 0;
        // 返回保证金变动后的值
        return _params.collateralDelta.toInt256() + dPNL;
    }

    function calculateNewCollateral(
        MarketDataTypes.Cache memory _params,
        Position.Props memory _position,
        int256 dPNL,
        int256 fees
    ) internal pure returns (uint256) {
        bool isCloseAll = _position.size == _params.sizeDelta;
        if (isCloseAll) _params.collateralDelta = _position.collateral;
        if (_params.liqState > 0 || isCloseAll) return 0; // 如果处于清算状态或者是全部清算，则返回0
        if (_position.collateral.toInt256() + dPNL - fees <= 0) return 0; // 如果保证金加上盈亏减去费用小于等于0，则返回0
        if (_params.collateralDelta.toInt256() + dPNL - fees < 0) {
            return (_position.collateral.toInt256() + dPNL - fees).toUint256();
        } // 如果保证金增量加上盈亏减去费用小于0，则返回保证金加上盈亏减去费用的值
        return _position.collateral - _params.collateralDelta; // 否则返回保证金减去保证金增量的值
    }

    /**
     * 计算用户保证金亏损
     * @param coll 用户仓位保证金 18 decimals
     * @param pnl 盈亏金额 18 decimals
     * @param fs 手续费数组 18 decimals
     * @return fundFeeLoss 资金费亏损 18 decimals
     */
    function calculateFundFeeLoss(
        int256 coll, // 用户仓位保证金
        int256 pnl, // 盈亏金额
        int256[] memory fs // 手续费数组
    ) internal pure returns (uint256 fundFeeLoss) {
        int256 fFee = fs[uint8(FeeType.T.FundFee)]; // 资金费用
        int256 remain = -fs[uint8(FeeType.T.CloseFee)] + coll + pnl; // 剩余资金
        if (fFee > 0 && fFee > remain) {
            return uint256(fFee - SignedMath.max(remain, 0));
        } // 计算资金费用亏损
    }

    struct DecreaseTransactionOuts {
        // 计算转入费用金库的金额
        int256 transToFeeVault;
        // 计算转入金库的金额
        int256 transToVault;
        uint256 newCollateralUnsigned;
        int256 transToUser;
        // 从费用金库中计算提取金额和剩余手续费
        int256 withdrawFromFeeVault;
        // 需要在事件上触发的collateral变化值(包含 collateral 和 withdrawFromFeeVault)
        int256 collateralDeltaAfter;
        // 需要在 position 上面减少的 collateral 数量(不包含withdrawFromFeeVault)
        uint256 collateralDecreased;
    }

    function calDecreaseTransactionValues(
        MarketDataTypes.Cache memory _params,
        Position.Props memory _position,
        int256 dPNL,
        int256[] memory _originFees
    ) internal pure returns (DecreaseTransactionOuts memory outs) {
        // 从手续费保险库中计算提取金额和剩余手续费
        (int256 withdrawFromFeeVault, int256[] memory afterFees) = calculateWithdrawFromFeeVault(_originFees);
        int256 totalFees = afterFees.totoalFees();
        // 如果提取金额大于0，则增加头寸保证金
        if (withdrawFromFeeVault > 0) {
            // 零时增加, 方便计算
            _position.collateral += uint256(withdrawFromFeeVault);
            outs.withdrawFromFeeVault = withdrawFromFeeVault;
        }
        // 计算转入手续费保险库的金额
        outs.transToFeeVault = calculateTransToFeeVault(_position, dPNL, totalFees) - withdrawFromFeeVault;
        // 计算转入保险库的金额
        outs.transToVault = calculateTransToVault(_position.collateral.toInt256(), dPNL);
        // 计算新的保证金金额（无符号）
        outs.newCollateralUnsigned = calculateNewCollateral(_params, _position, dPNL, totalFees);
        // 计算转入用户的金额
        outs.transToUser = calculateTransToUser(_params, _position, dPNL, totalFees);
        // 计算完毕, 数据还原

        // 如果仓位大小等于参数中的大小变化，则从保证金中扣除提取的金额
        if (_position.size == _params.sizeDelta) {
            _position.collateral -= withdrawFromFeeVault.toUint256();
            _params.collateralDelta = _position.collateral;
        }

        // 计算保证金减少的金额
        outs.collateralDecreased = _position.collateral - outs.newCollateralUnsigned;

        // 计算保证金变化后的值，如果仓位大小等于参数中的大小变化，则为保证金本身，否则为保证金减少的金额减去提取的金额
        outs.collateralDeltaAfter = (_position.size == _params.sizeDelta)
            ? _position.collateral.toInt256()
            : outs.collateralDecreased.toInt256() - outs.withdrawFromFeeVault;
    }

    function isClearPos(
        MarketDataTypes.Cache memory _params, // 定义更新仓位所需的参数
        Position.Props memory _position // 定义当前仓位的属性
    ) internal pure returns (bool) {
        return (_params.liqState != 1 || _params.liqState != 2) && _params.sizeDelta != _position.size;
    }
}
