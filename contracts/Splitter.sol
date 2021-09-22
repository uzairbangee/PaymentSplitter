// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./ApiToken.sol";
import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/payment/PaymentSplitter.sol";

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
    }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract PaymentSplitter {
    
    using SafeMath for uint;

    IERC20 public token;

    uint256 internal totalContractAmount = 0;
    uint256 internal _percentageSum = 0;
    uint256 _totalRecipients = 0;
    uint256 private _totalReleased = 0;
    
    mapping (uint256 => address) public recipients;
    mapping (address => uint256) public _shares;
    mapping(address => uint256) private _released;

    constructor() {
        token = new ApiToken();
    }

    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    function totalRecipients() public view returns (uint256) {
        return _totalRecipients;
    }

    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }


    function fundContract () public payable {
        require(msg.value > 0, "Royalty amount must be higher than 0");
        totalContractAmount = totalContractAmount.add(msg.value);
    }

    function addRecipient (uint256 percentage, address _address) public {

        require(percentage > 0 && percentage <= 100 && (percentage + _percentageSum) <= 100, "Percentages are not valid");
        recipients[_totalRecipients] = _address;
        _shares[_address] = percentage;
        ++_totalRecipients;

        _percentageSum = _percentageSum.add(percentage);
    }

    function payRecipients() public payable returns (bool success) {

        require (totalContractAmount > 0, "No funds have been sent to the contract");
        if (_percentageSum != 100) {
            return false;
        } 
        else {
            uint256 contractPercentageAmount;
            contractPercentageAmount = totalContractAmount.div(100);
            for (uint256 i = 0; i < _totalRecipients; i++) {

                uint256 amount = contractPercentageAmount.mul(_shares[recipients[i]]);
                payable(recipients[i]).transfer(amount);
                totalContractAmount = totalContractAmount.sub(amount);

                _released[recipients[i]] = _released[recipients[i]] + amount;
                _totalReleased = _totalReleased + amount;
            }

        }

        return true;
        
    }

}