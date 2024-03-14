// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibAccessManaged} from "../ac/LibAccessManaged.sol";
import {ReferralHandler} from "../lib/referral/ReferralHandler.sol";

contract ReferralFacet {
    function setTier(uint256 _tierId, uint256 _totalRebate, uint256 _discountShare) external restricted {
        ReferralHandler.setTier(_tierId, _totalRebate, _discountShare);
    }

    function setReferrerTier(address _referrer, uint256 _tierId) external restricted {
        ReferralHandler.setReferrerTier(_referrer, _tierId);
    }

    function setReferrerDiscountShare(address _account, uint256 _discountShare) external restricted {
        ReferralHandler.setReferrerDiscountShare(_account, _discountShare);
    }

    function setTraderReferralCode(address _account, bytes32 _code) external restricted {
        ReferralHandler._setTraderReferralCode(_account, _code);
    }

    function setTraderReferralCodeByUser(bytes32 _code) external {
        ReferralHandler._setTraderReferralCode(msg.sender, _code);
    }

    function registerCode(bytes32 _code) external {
        ReferralHandler.registerCode(_code);
    }

    function setCodeOwner(bytes32 _code, address _newAccount) external {
        ReferralHandler.setCodeOwner(_code, _newAccount);
    }

    function govSetCodeOwner(bytes32 _code, address _newAccount) external restricted {
        ReferralHandler.govSetCodeOwner(_code, _newAccount);
    }

    //========================================================================
    //      view functions
    //========================================================================

    function getTraderReferralInfo(address _account) internal view returns (bytes32, address) {
        return ReferralHandler.getTraderReferralInfo(_account);
    }

    function getCodeOwners(bytes32 _code) external view returns (address) {
        return ReferralHandler.codeOwners(_code);
    }
}
