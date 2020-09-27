pragma solidity 0.6.6;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";

/**
 * @title OrbitDbAPIConsumer is an example contract which requests data from
 * the Chainlink network
 * @dev This contract is designed to work on multiple networks, including
 * local test networks
 */
contract OrbitDbAPIConsumer is ChainlinkClient {
  uint256 public ethereumPrice;

  address private oracle;
  bytes32 private jobId;
  uint256 private fee;

  /**
   * @notice Deploy the contract with a specified address for the LINK
   * and Oracle contract addresses
   * @dev Sets the storage for the specified addresses
   * @param _link The address of the LINK token contract
   */
  constructor(address _link) public {
    if (_link == address(0)) {
      setPublicChainlinkToken();
    } else {
      setChainlinkToken(_link);
    }

    // Fix these for whatever network? These are Kovan
    oracle = 0x2f90A6D021db21e1B2A077c5a37B3C7E75D15b7e;
    jobId = "29fa9aa13bf1468788b7cc4a500a45b8";
    fee = 0.1 * 10 ** 18; // 0.1 LINK
  }

  /**
     * Create a Chainlink request to retrieve API response, find the target price
     * data, then multiply by 100 (to remove decimal places from price).
     */
  function requestEthereumPrice() public returns (bytes32 requestId) 
  {
      Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

      // Set the URL to perform the GET request on
      request.add("get", "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD");

      // Set the path to find the desired data in the API response, where the response format is:
      // {"USD":243.33}
      request.add("path", "USD");

      // Multiply the result by 100 to remove decimals
      request.addInt("times", 100);

      // Sends the request
      return sendChainlinkRequestTo(oracle, request, fee);
  }

  /**
    * Receive the response in the form of uint256
    */
  function fulfill(bytes32 _requestId, uint256 _price) public recordChainlinkFulfillment(_requestId)
  {
    ethereumPrice = _price;
  }

  /**
   * @notice Returns the address of the LINK token
   * @dev This is the public implementation for chainlinkTokenAddress, which is
   * an internal method of the ChainlinkClient contract
   */
  // function getChainlinkToken() public view returns (address) {
  //   return chainlinkTokenAddress();
  // }

  /**
   * @notice Creates a request to the specified Oracle contract address
   * @dev This function ignores the stored Oracle contract address and
   * will instead send the request to the address specified
   * @param _oracle The Oracle contract address to send the request to
   * @param _jobId The bytes32 JobID to be executed
   * @param _url The URL to fetch data from
   * @param _path The dot-delimited path to parse of the response
   * @param _times The number to multiply the result by
   */
  // function createRequestTo(
  //   address _oracle,
  //   bytes32 _jobId,
  //   uint256 _payment,
  //   string memory _url,
  //   string memory _path,
  //   int256 _times
  // )
  //   public
  //   onlyOwner
  //   returns (bytes32 requestId)
  // {
  //   Chainlink.Request memory req = buildChainlinkRequest(_jobId, address(this), this.fulfill.selector);
  //   req.add("url", _url);
  //   req.add("path", _path);
  //   req.addInt("times", _times);
  //   requestId = sendChainlinkRequestTo(_oracle, req, _payment);
  // }

  /**
   * @notice The fulfill method from requests created by this contract
   * @dev The recordChainlinkFulfillment protects this function from being called
   * by anyone other than the oracle address that the request was sent to
   * @param _requestId The ID that was generated for the request
   * @param _data The answer provided by the oracle
   */
  // function fulfill(bytes32 _requestId, uint256 _data)
  //   public
  //   recordChainlinkFulfillment(_requestId)
  // {
  //   data = _data;
  // }

  /**
   * @notice Allows the owner to withdraw any LINK balance on the contract
   */
  // function withdrawLink() public onlyOwner {
  //   LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
  //   require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
  // }

  /**
   * @notice Call this method if no response is received within 5 minutes
   * @param _requestId The ID that was generated for the request to cancel
   * @param _payment The payment specified for the request to cancel
   * @param _callbackFunctionId The bytes4 callback function ID specified for
   * the request to cancel
   * @param _expiration The expiration generated for the request to cancel
   */
  // function cancelRequest(
  //   bytes32 _requestId,
  //   uint256 _payment,
  //   bytes4 _callbackFunctionId,
  //   uint256 _expiration
  // )
  //   public
  //   onlyOwner
  // {
  //   cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
  // }
}
