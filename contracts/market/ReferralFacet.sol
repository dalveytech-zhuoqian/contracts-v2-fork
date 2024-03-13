// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibAccessManaged} from "../lib/ac/LibAccessManaged.sol";
import {LibReferral} from "../lib/referral/LibReferral.sol";

contract ReferralFacet {
    function setTier(uint256 _tierId, uint256 _totalRebate, uint256 _discountShare) external restricted {
        LibReferral.setTier(_tierId, _totalRebate, _discountShare);
    }

    function setReferrerTier(address _referrer, uint256 _tierId) external restricted {
        LibReferral.setReferrerTier(_referrer, _tierId);
    }

    function setReferrerDiscountShare(address _account, uint256 _discountShare) external restricted {
        LibReferral.setReferrerDiscountShare(_account, _discountShare);
    }

    function setTraderReferralCode(address _account, bytes32 _code) external restricted {
        LibReferral._setTraderReferralCode(_account, _code);
    }

    function setTraderReferralCodeByUser(bytes32 _code) external {
        LibReferral._setTraderReferralCode(msg.sender, _code);
    }

    function registerCode(bytes32 _code) external {
        LibReferral.registerCode(_code);
    }

    function setCodeOwner(bytes32 _code, address _newAccount) external {
        LibReferral.setCodeOwner(_code, _newAccount);
    }

    function govSetCodeOwner(bytes32 _code, address _newAccount) external restricted {
        LibReferral.govSetCodeOwner(_code, _newAccount);
    }

    //========================================================================
    //      view functions
    //========================================================================

    function getTraderReferralInfo(address _account) internal view returns (bytes32, address) {
        return LibReferral.getTraderReferralInfo(_account);
    }

    function getCodeOwners(bytes32 _code) external view returns (address) {
        return LibReferral.codeOwners(_code);
    }
}
