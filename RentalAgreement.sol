//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


 interface RentControl {
    function storePrice(uint256 unit, uint256 price) external;

    function retrievePrice(uint256 unit) external view returns (uint256);
 }
 
/**
 * @title RentalAgreement
 * @dev defines a rental agreement between two parties, links to another smart contract
 */

contract RentalAgreement {

    uint256 thisUnit;  
    uint256 unitPrc; //price of unit       
    address  public contractAddress;

    /**
     * @dev set the contract address of the RentScan contract
     * @param ctrAddr the address of the contract
     */
    function setContractAddress (address ctrAddr) public {
        contractAddress = ctrAddr;
    }
     /**
     * @dev stores rental agreement in smart contract state if the price is valid in RentScan
     * @param unit the rental unit being rented
     * @param price the price for the lease
     */
    function rent(uint256 unit, uint256 price) public {
        
        //try to adjust price within rental agreement; propogates revert?
        try RentControl(contractAddress).storePrice(unit, price)
        {
            thisUnit = unit;
            unitPrc = price;
        } catch {
            revert("unable to sign agreement, cannot store price, either price is over rent cap or within waiting period");
        } 
    }

}
