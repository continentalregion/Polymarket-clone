// File: contracts/lib/InitializableOwnable.sol

/**
 * @title Ownable
 * @author DODO Breeder
 *
 * @notice Ownership related functions
 */
contract InitializableOwnable {
    address public _OWNER_;
    address public gefy;
    bool internal _INITIALIZED_;
 uint256 public totalMarkets = 0;
    constructor(address _gefy) {
        owner = msg.sender;
        gefy = _gefy;
    }
}
 mapping(uint256 => Markets) 0x6Fd3D33989cdDc617712d8f81DEe3cE80C68174A Markets;

    struct Markets {
        uint256 id;
        string  market;
        uint256 timestamp;
        uint256 endTimestamp;
        address createdBy;
        string creatorImageHash;
        AmountAdded[] yesCount;
        AmountAdded[] noCount;
        uint256 totalAmount;
        uint256 totalYesAmount;
        uint256 totalNoAmount;
        bool eventCompleted;
        string description;
        string resolverUrl;
    }

    struct AmountAdded {
        address user;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => uint256) public winningAmount;
    address[] public winningAddresses;
    
    event MarketCreated(
        uint256 id,
        string market,
        uint256 timestamp,
        address createdBy,
        string creatorImageHash,
        uint256 totalAmount,
        uint256 totalYesAmount,
        uint256 totalNoAmount
    );function createMarket(
        string memory _market,
        string memory _creatorImageHash,
        string memory _description,
        string memory _resolverUrl,
        uint256 _endTimestamp
    ) public {
        require(msg.sender == owner, "Unauthorized");
        uint256 timestamp = block.timestamp;

        Markets storage market = markets[totalMarkets];
        market.id = totalMarkets++;
        market.market = _market;
        market.timestamp = timestamp;
        market.createdBy = msg.sender;
        market.creatorImageHash = _creatorImageHash;
        market.totalAmount = 0;
        market.totalYesAmount = 0;
        market.totalNoAmount = 0;
        market.description = _description;
        market.resolverUrl = _resolverUrl;
        market.endTimestamp = _endTimestamp;

        emit MarketCreated(
            totalMarkets,
            _market,
            timestamp,
            msg.sender,
            _creatorImageHash,
            0,
            0,
            0
        );
    }
function addYesBet(uint256 _marketId, uint256 _value) public payable {
        require(_value <= ERC20(gefy).allowance(msg.sender, address(this)), "Not allowed to spend this amount.");
        Markets storage market = markets[_marketId];
        ERC20(gefy).transferFrom(msg.sender, address(this), _value);
        AmountAdded memory amountAdded = AmountAdded(
            msg.sender,
            _value,
            block.timestamp
        );

        market.totalYesAmount += _value;
        market.totalAmount += _value;
        market.yesCount.push(amountAdded);
    }

    function addNoBet(uint256 _marketId, uint256 _value) public payable {
        require(_value <= ERC20(gefy).allowance(msg.sender, address(this)), "Not allowed to spend this amount.");
        Markets storage market = markets[_marketId];
        ERC20(gefy).transferFrom(msg.sender, address(this), _value);
        AmountAdded memory amountAdded = AmountAdded(
            msg.sender,
            _value,
            block.timestamp
        );

        market.totalNoAmount += _value;
        market.totalAmount += _value;
        market.noCount.push(amountAdded);
    }
  function getGraphData(uint256 _marketId)
        public
        view
        returns (AmountAdded[] memory, AmountAdded[] memory)
    {
        Markets storage market = markets[_marketId];
        return (market.yesCount, market.noCount);
    }
    function distributeWinningAmount(uint256 _marketId, bool eventOutcome)
        public
        payable
    {
        require(msg.sender == owner, "Unauthorized");

        Markets storage market = markets[_marketId];
        if (eventOutcome) {
            for (uint256 i = 0; i < market.yesCount.length; i++) {
                uint256 amount = (market.totalNoAmount *
                    market.yesCount[i].amount) / market.totalYesAmount;
                winningAmount[market.yesCount[i].user] += (amount +
                    market.yesCount[i].amount);
                winningAddresses.push(market.yesCount[i].user);
            }

            for (uint256 i = 0; i < winningAddresses.length; i++) {
                address payable _address = payable(winningAddresses[i]);
                ERC20(polyToken).transfer(_address, winningAmount[_address]);
                delete winningAmount[_address];
            }
            delete winningAddresses;
        } else {
            for (uint256 i = 0; i < market.noCount.length; i++) {
                uint256 amount = (market.totalYesAmount *
                    market.noCount[i].amount) / market.totalNoAmount;
                winningAmount[market.noCount[i].user] += (amount +
                    market.noCount[i].amount);
                winningAddresses.push(market.noCount[i].user);
            }

            for (uint256 i = 0; i < winningAddresses.length; i++) {
                address payable _address = payable(winningAddresses[i]);
                ERC20(gefy).transfer(_address, winningAmount[_address]);
                delete winningAmount[_address];
            }
            delete winningAddresses;
        }
        market.eventCompleted = true;
    }
