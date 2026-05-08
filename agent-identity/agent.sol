// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract predictBNBidentity {

    struct Soul {
        uint256 id;
        string name;
        string username;
        address tokenAddress;
        address soulOwner;
        string metadataURI;
        uint256 createdAt;
    }

    // Main storage
    mapping(uint256 => Soul) public souls;

    // Username uniqueness
    mapping(string => bool) public usernameTaken;

    // Prevent duplicate IDs
    mapping(uint256 => bool) private usedIds;

    // Event for indexing (BscScan / custom explorer)
    event SoulCreated(
        uint256 indexed id,
        string name,
        string username,
        address tokenAddress,
        address indexed soulOwner,
        string metadataURI
    );

    // 🔥 Generate pseudo-random 6-digit ID
    function _generateId() internal view returns (uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    msg.sender,
                    block.prevrandao
                )
            )
        ) % 900000 + 100000;
    }

    // 🚀 Create On-Chain Identity
    function createSoul(
        string memory _name,
        string memory _username,
        address _tokenAddress
    ) public returns (uint256) {

        require(!usernameTaken[_username], "Username already taken");

        uint256 newId = _generateId();

        // Prevent collision
        while (usedIds[newId]) {
            newId = (newId + 1) % 900000 + 100000;
        }

        usedIds[newId] = true;
        usernameTaken[_username] = true;

        // Default metadata (can be upgraded to IPFS later)
        string memory metadata = string(
            abi.encodePacked("soul://", _username)
        );

        souls[newId] = Soul({
            id: newId,
            name: _name,
            username: _username,
            tokenAddress: _tokenAddress,
            soulOwner: msg.sender,
            metadataURI: metadata,
            createdAt: block.timestamp
        });

        emit SoulCreated(
            newId,
            _name,
            _username,
            _tokenAddress,
            msg.sender,
            metadata
        );

        return newId;
    }

    // 🔍 Get full identity (explorer-friendly)
    function getSoul(uint256 _id) public view returns (
        uint256,
        string memory,
        string memory,
        address,
        address,
        string memory,
        uint256
    ) {
        Soul memory s = souls[_id];
        return (
            s.id,
            s.name,
            s.username,
            s.tokenAddress,
            s.soulOwner,
            s.metadataURI,
            s.createdAt
        );
    }

    // 🔎 Check username availability
    function isUsernameTaken(string memory _username) public view returns (bool) {
        return usernameTaken[_username];
    }
}
