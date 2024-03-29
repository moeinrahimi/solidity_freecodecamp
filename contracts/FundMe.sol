
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "./PriceConverter.sol";
error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD=10*1e18; 
    address[] public funders;
    mapping (address=> uint256) public  addressToAmountFunded;
    address public immutable owner;
  
    constructor(){
        owner = msg.sender;
    }
    
    function fund() public payable  {
        require(msg.value.getConversionRate() >= MINIMUM_USD,"Didn't send enough!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
      modifier onlyOwner{
        if (msg.sender != owner) revert NotOwner();
        _;
    }


    function withdraw() public onlyOwner{
        
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++) 
        {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder]=0;
        }
        funders = new address[](0);
        (bool callSuccess,)= payable (msg.sender).call{value:address(this).balance}("");
        require(callSuccess,"Call failed");
    }

    receive() external payable { 
        fund();
    }
    fallback() external payable { 
        fund();
    }
  

    
 
    
}