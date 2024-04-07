// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Common} from "chainlink_8_contracts/src/v0.8/libraries/Common.sol";

import {IVerifierFeeManager} from "chainlink_8_contracts/src/v0.8/llo-feeds/interfaces/IVerifierFeeManager.sol";

// IVerifierProxy 和 IFeeManager 的自定义接口
interface IVerifierProxy {
    function verify(
        bytes calldata payload,
        bytes calldata parameterPayload
    ) external payable returns (bytes memory verifierResponse);

    function s_feeManager() external view returns (IVerifierFeeManager);
}

interface IFeeManager {
    function getFeeAndReward(
        address subscriber,
        bytes memory unverifiedReport,
        address quoteAddress
    ) external returns (Common.Asset memory, Common.Asset memory, uint256);

    function i_linkAddress() external view returns (address);

    function i_nativeAddress() external view returns (address);

    function i_rewardManager() external view returns (address);
}
