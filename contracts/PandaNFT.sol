// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PandaNFT is ERC721, Ownable {

    uint256 private COUNTER;

    uint256 public mintingFee = 0.01 ether;
    uint256 public divineLeft = 50;
    uint256 public impLeft = 300;
    
    // Have a mapping to add new classes
    // string[] public classes; // Loop through to find availabilities
    // mapping (string => uint256) private classAvailabilities; // SEE IF YOU CAN USE STRINGS AS MAPPING KEYS
    // classAvailabilities[divine] = 50;
    // classAvailabilities[imp] = 300;

    struct Panda {
        string name;
        uint256 id;
        uint256 dna; // HOW MUCH DO WE WANT TO PUT ON CHAIN //KEEP ONLY THINGS THAT WONT CHANGE (NAME, ID, RARITY
        uint256 level; // CHANGING THINGS ON THE BLOCKCHAIN CAN COST AND BE A BARRIER FOR PLAYERS. wE CAN DO ALL THIS LOGIC ON THE FRONTEND WITH THE GAME DEVS
        uint256 rarity; // 50 Divine and 300 Imp and others but set with block.timestamp when the other rarities are accessible
        uint256 birthTime; // Set this with block.timestamp, include function to mature (require birthTime < block.timestamp + 10 days)
        bool isAdult; // Call hatch function to set this to true after 3 days
    }

    Panda[] private Pandas;

    event NewPanda(address indexed owner, uint256 indexed id, uint256 indexed dna);

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol) {}


    // Create Panda
    function mintPanda(string memory _name) payable public {
        require(impLeft + divineLeft > 0, "No characters available to mint at the moment. Check back later.");
        require(msg.value == mintingFee, "Please send the correct minting fee.");
        _mintPanda(msg.sender, _name);
    }


    // Hatch Panda
    function hatchPanda(uint256 _id) public {
        // require(ownerOf(NFT) == msg.sender/has ownership)
        // require(Panda.id.birthTime + 10 days >= block.timestamp, "Your panda is not ready yet.");
        // Panda.id.isAdult = true;
    }


    // HELPERS
    // Generate Random Number
    function _genRandomNum(uint256 _mod) internal view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))); // Find more secure way of gen random numbers
        return randomNumber % _mod;
    }

    // Internal Mint Function
    function _mintPanda(address _to, string memory _name) internal {

        uint256 _dna = _genRandomNum(10**16);
        uint8 randRarity = uint8(_genRandomNum(divineLeft + impLeft));
        if(randRarity > impLeft) { // THIS WILL CHANGE BASED ON HOW MANY CLASSES WE HAVE
            divineLeft -= 1;        //
        } else {
            impLeft -= 1;
        }

        Panda memory newPanda = Panda(_name, COUNTER, _dna, 1, randRarity, block.timestamp, false);
        Pandas.push(newPanda);
        _safeMint(_to, COUNTER);

        emit NewPanda(msg.sender, COUNTER, _dna);
        COUNTER++;
    }


    // Admin Functions
    function setRarities(uint256 _divine, uint256 _imp) external onlyOwner {
        divineLeft = _divine;
        impLeft = _imp;
    }

    function setMintingFee(uint256 _fee) external onlyOwner {
        mintingFee = _fee * 10**18; // Set minting fee in BNB
    }

    function withdrawBNB() external onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }
}