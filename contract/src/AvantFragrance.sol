// SPDX-License-Identifier: VPL
pragma solidity ^0.8.13;

import "solady/Milady.sol";
import "erc721a/ERC721A.sol";

error SaleInactive();
error NoMoreFragrances();
error BrokeNiggaAlert();
error NotOnList();

contract AvantFragrance is ERC721A, Ownable {
    //using MerkleProofLib for bytes32[];
    mapping(address => bool) private _whitelist;

    bytes32 public merkleRoot;

    uint256 public constant MAX_FRAGRANCES = 100;
    uint256 public constant nftPrice = 0.1 ether;
    string _baseTokenURI;
    bool internal _saleIsActive = false;

    constructor(string memory baseURI, bytes32 _merkleRoot) ERC721A("Avant Fragrance", "AF") {
        _initializeOwner(msg.sender);
        _baseTokenURI = baseURI;
        merkleRoot = _merkleRoot;
    }

    modifier saleIsActive() {
        if(!_saleIsActive)
        {
            revert SaleInactive();
        }
        _;
    }

    function isWhitelisted(/*bytes32[] memory _merkleProof*/) internal view returns (bool){
        //bytes32 leafHash = keccak256(abi.encodePacked(msg.sender));
        //return _merkleProof.verify(merkleRoot, leafHash);
        return _whitelist[msg.sender];
    }

    function addWhitelist(address[] memory addresses) public onlyOwner {
        for(uint256 i = 0; i < addresses.length; i++){
            _whitelist[addresses[i]] = true;
        }
    }

    function freeMint(/*bytes32[] memory _merkleProof*/) external saleIsActive
    {
        if(_totalMinted() == MAX_FRAGRANCES) {
            revert NoMoreFragrances();
        }
        if(!isWhitelisted(/*_merkleProof*/)){
            revert NotOnList();
        }
        _safeMint(msg.sender, 1);
        _whitelist[msg.sender] = false;
    }

    function mint(uint256 quantity) external payable saleIsActive {
        if(quantity + _totalMinted() > MAX_FRAGRANCES) {
            revert NoMoreFragrances();
        }
        if(nftPrice * quantity > msg.value) {
            revert BrokeNiggaAlert();
        }
        _safeMint(msg.sender, quantity);
    }

    function reserveMint(uint256 quantity) public onlyOwner {
        if(quantity + _totalMinted() > MAX_FRAGRANCES) {
            revert NoMoreFragrances();
        }
        _safeMint(msg.sender, quantity);
    }

    function flipSaleState() public onlyOwner {
        _saleIsActive = !_saleIsActive;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function totalMinted() public view virtual returns (uint256) {
        return _totalMinted();
    }
}
