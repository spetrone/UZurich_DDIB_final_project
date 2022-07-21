// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title RentControl
 * @dev Store & retrieve value in a variable
 */
contract RentControl{


  struct unitValues {
      uint256 unitPrice;
      uint256 timestamp;
  }

    
  mapping(uint256 => unitValues) rentals;


  uint256 public _incRate = 2; //increase rate cap, default is 2%
  uint256 public period = 4 minutes;  //shortened for testing

   //Declare an Event
   event updateUnitPrice(uint256 unitNum, uint256 prc);

    /**
     * @dev Store value in variable
     * @param price value to store
     * @param unit the housing unit the price is stored at
     */
    function storePrice(uint256 unit, uint256 price) public {
    
        //initial price storage transaction
        if (rentals[unit].unitPrice == 0 ) {
             rentals[unit].unitPrice = price; //initial
             rentals[unit].timestamp = block.timestamp; //update timestamp
        }
        else { //test if the new increase is within the rate cap
       
            if ((rentals[unit].unitPrice * (100 + _incRate)) >= price * 100) {

                //test if new increase is outside of time limit (can only be changed every so often)
                //prices can always be changed to be lower or the same, even within the waiting period
                if((block.timestamp >= rentals[unit].timestamp + period) || price <= rentals[unit].unitPrice) {
                    rentals[unit].unitPrice = price;
                    rentals[unit].timestamp = block.timestamp; //update timestamp
                    //Emit an event to track changes/history off-chain
                    emit updateUnitPrice(unit, price); 

                } else {
                    revert("Price cannot change within the given time period");
                }
               
            }
            else {
                revert("Price increase is higher than rate increase cap; transaction cancelled");
            }
        }
      
    }

    /**
     * @dev Return current price of a unit
     * @param unit - the unit to retrieve the current price from
     * @return price of 'unit'
     */
    function retrievePrice(uint256 unit) public view returns (uint256){
        return rentals[unit].unitPrice;
    }

    /**
     * @dev Return timestamp of a unit 
     * @param unit - the unit to retrieve the current price from
     * @return timestamp of 'unit'
     */
    function retrieveTimestamp(uint256 unit) public view returns (uint256){
        return rentals[unit].timestamp;
    }

       /**
     * @dev Return period of waiting time in contract
     * @return period
     */
    function retrievePeriod() public view returns (uint256){
        return period;
    }

           /**
     * @dev Return rate increase cap
     * @return increase rate cap for rent
     */
    function retrieveRate() public view returns (uint256){
        return _incRate;
    }
}
