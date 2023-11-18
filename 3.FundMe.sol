//SPDX-Lisence_Identifier : MIT

pragma solidity >=0.6.6 < 0.9.0;


//For using the the conversion rate we need to import chainlink contract.

// import "@chainlink/contracts/src/v0./interfaces/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

// We are creating a function which accept payments from a sender.

interface AggregatorV3Interface {   //this interfaces allows us to call those contracts have these functions - decimals() etc.

  function decimals() external view returns (
      uint8
    );

  function description() external view returns
   (
      string memory
    );

  function version() external view returns
    (
      uint256
    );

  function getRoundData(uint80 _roundId ) external view returns
    (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData() external view returns
     (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
contract FundMe {
    // Now we want to track the transactions so for this we are going to create a mapping function between address and value.
    mapping (address => uint256) public AddressToFund ;
    address owner;

    address[] public funders;  // to store sddress of the sender.
    // to create a owner the instant the contract is deployed we use constructors

    constructor() public {
        owner = msg.sender;
    }
    //payable functions are created to accept funds from the sender.
    function Fund() public payable { // this is the function which accepts payment
      // we are going to specify the minimum requirement.
      uint256 minimumUSD = 50;
      require(getConvertor(msg.value)>= minimumUSD , 'You need to spend More');
      
      
        // now to keep track we are using msg.sender and msg.value
        // msg.sender - contains the address.
        // msg.value - contains the value.       
        AddressToFund[msg.sender] += msg.value;  // this function continuously adding the the value paid to it.
        // Now we need the conversion rate of ETH to various currencies.
        funders.push(msg.sender);
    }

    // now we are going to interact with the interfaces , which is similar to interact with an struct.

    function getVersion() public view returns(uint256){  // we are using view as we are only reading it .
        // for interacting we first specfies which we want to interact and then name it. simlpy like creating a object named PriceFeed.
        AggregatorV3Interface PriceFeed = AggregatorV3Interface(0x62F85E814C97eb9c6d2E03F9d1b1a7077FEA2078);
        return PriceFeed.version();
    }

    // we are access the latestRoundData() particularly answer in it .\
    // as we see latestRoundData() is a tuple , so we also need to return a tuple.

    function getPrice() public view returns(uint256){
         AggregatorV3Interface PriceFeed = AggregatorV3Interface(0x62F85E814C97eb9c6d2E03F9d1b1a7077FEA2078);
           
                                                        // uint80 roundId,
                                                        // int256 answer,
                                                        // uint256 startedAt,
                                                        // uint256 updatedAt,
                                                        // uint80 answeredInRound

    (,int256 answer ,,,)  =PriceFeed.latestRoundData(); // we can use it.
        return uint256(answer); // as we are returning uint256 but answer is int256 we need to type cast it.
    }

    // now we converting ETH to usd
    function getConvertor(uint256 ethAmount) public view returns(uint256){
        uint256 ethPrice = getPrice();  // it will take price feed from fetPrice()
        uint256 ethAmountToUsd = (ethPrice * ethAmount);
        return ethAmountToUsd;
    }

    //to ensure the onwer only withdraw we use modifiers.
    modifier OnlyOwner{       // it restrict function and only owner get to access it.
        require(msg.sender == owner , "you need to be the owner");
        _;   // to specify where the modifier code it inserted.
    } 

    // now we are going to create a function which withdraws the ETH we spend.to the sender
    function withdraw() payable OnlyOwner public {
        // to be the owner we need to create a createowner function but what if someone access this function which make it to change the owner.
        
        payable (owner).transfer(address(this).balance);  // we need to ensure that msg.sender is the contract owner.

        //now we are setting the funds to zero we need a for loop.
        for (uint256 funderIndex = 0; funderIndex < funders.length ; funderIndex++){
                address funder = funders[funderIndex];
                AddressToFund[funder] = 0;
        }

        funders = new address[](0); // to set the array.
    }

}