// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "solmate/utils/MerkleProofLib.sol";
import "solmate/tokens/ERC1155.sol";
import "./Base64.sol";

contract Abeg1155 is ERC1155 {
    bytes32 immutable merkleRoot;

    constructor(bytes32 _merkleRoot) {
        merkleRoot = _merkleRoot;
    }

    mapping(address => bool) public hasClaimed;

    function claim(
        address _claimer,
        uint256 _tokenId,
        uint256 _amount,
        bytes32[] calldata _proof
    ) external returns (bool success) {
        require(!hasClaimed[_claimer], "already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(_tokenId, _claimer, _amount));
        bool verificationStatus = MerkleProofLib.verify(
            _proof,
            merkleRoot,
            leaf
        );
        require(verificationStatus, "not whitelisted");
        hasClaimed[_claimer] = true;
        _mint(_claimer, _tokenId, _amount, bytes(generateTokenURI(generateImageURI(_tokenId))));
        success = true;
    }

    function uri(
        uint256 id
    ) public view virtual override returns (string memory) {
        return "";
    }

    function generateImageURI(
        uint256 _tokenId
    ) public pure returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            _tokenId,
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function generateTokenURI(string memory imageURI)
        public
        pure
        returns (string memory)
    {
        string memory baseURL = "data:application/json;base64,";
        string memory json = string(
            abi.encodePacked(
                '{"name": "Merkle1155 NFT", "description": "An ERC1155 SVG based on-chain NFT", "image":"',
                imageURI,
                '"}'
            )
        );
        string memory jsonBase64Encoded = Base64.encode(bytes(json));
        return string(abi.encodePacked(baseURL, jsonBase64Encoded));
    }
}