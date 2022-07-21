//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


 interface RentControl {
    function retrievePeriod() external view returns (uint256);
    function retrieveRate() external view returns (uint256);
    function storePrice(uint256 unit, uint256 price) external;
    function retrievePrice(uint256 unit) external view returns (uint256);
    function retrieveTimestamp(uint256 unit) external view returns (uint256);
 }
 
/**
 * @title MutualRentalAgreement
 * @dev defines a rental agreement between two parties, links to another smart contract
 */

contract MutualRentalAgreement {

    uint256 thisUnit;  
    uint256 unitPrc; //price of unit     
    address  public contractAddress;
    address public landlord;
    address public tenant;
    uint256 landlordTimestamp;
    uint256 timeoutPeriod = 4 minutes;

    struct approvalStruct {
        bool approvedByLandlord;
        bool approvedByTenant;
    }

    approvalStruct approvals;
    /**
     * @dev set the contract address of the RentScan contract
     * @param ctrAddr the address of the contract
     */
    function setContractAddress (address ctrAddr) public {
        contractAddress = ctrAddr;
    }

    /**
     * @dev set the addresses of landlord 
     * @param lAddr the landlord's address
     */
    function setLandlord(address lAddr) public {
        landlord = lAddr;
    }

    /**
     * @dev set the addresses of tenant
     * @param tAddr the landlord's address
     */
    function setTenant(address tAddr) public {
        tenant = tAddr;
    }

     /**
     * @dev stores rental agreement in smart contract state if the price is valid in the storage contract
     * @param unit the rental unit being rented
     * @param price the price for the lease
     */
    function landlordSign(uint256 unit, uint256 price) public returns (bool approved) {

        bool success = false; //flag

        if(msg.sender != landlord) 
            revert("invalid user, not the landlord"); // not the landlord, abort
        else{

            //set timer and boolean variable, along with the unit and price
            thisUnit = unit;
            unitPrc = price;
            landlordTimestamp = block.timestamp;
            success = true;

        }

        return success;
    }



    
     /**
     * @dev tenant signs agreement, succesful if prices agree and contract has not timedout
     * @param tenantUnit the rental unit being rented
     * @param tenantPrice the price for the lease
     * @return approved whether or not the tenant approved
     */
    function tenantSign(uint256 tenantUnit, uint256 tenantPrice) public returns (bool approved) {

        bool success = false;
    
        if(landlordTimestamp + timeoutPeriod < block.timestamp) {
             //reset state
            thisUnit = 0;
            unitPrc = 0;
            revert("contract timed-out between signatures");
        }
        else if (thisUnit == 0 || landlordTimestamp == 0) {
            revert ("Landlord has not created an agreement yet");
        }
        else {
             if(msg.sender == tenant && tenantUnit == thisUnit && tenantPrice == unitPrc) {

                //try to adjust price within rental agreement; propogates revert?
                try RentControl(contractAddress).storePrice(tenantUnit, tenantPrice){
                     //reset state
                    thisUnit = 0;
                    unitPrc = 0;
                    success = true;
                } 
                catch {
                    revert("unable to sign agreement, cannot store price");
                } 

                //reset state
                thisUnit = 0;
                unitPrc = 0;
            }
            else {
                if (msg.sender != tenant) 
                    revert("invalid user, not tenant");
                else if (tenantUnit != thisUnit) 
                    revert("error, mismatching unit numbers");
                else if (tenantPrice == unitPrc) 
                    revert("error, mismatching prices for unit");
                else revert("tenant signature failed");
            }
        }
        return success;
    }
        
       
}
