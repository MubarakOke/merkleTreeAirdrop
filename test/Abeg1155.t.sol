// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";

import {Abeg1155} from "../src/Abeg1155.sol";

contract Abeg1155Test is Test {
    using stdJson for string;
    Abeg1155 public merkle;
    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    struct User {
        address user;
        uint256 id;
        uint256 amount;
    }
    Result public result;
    User public user;
    bytes32 root =
        0x5d49cb60cac3ba160a21d9af9a894c2cad43899725e8abacb4639a711c49ad4a;
    address user1 = 0x497c773A992f02aD378BbD5742d4fa184E89206f;

    function setUp() public {
        merkle = new Abeg1155(root);
        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkle_tree.json");

        string memory json = vm.readFile(path);
        string memory data = string.concat(_root, "/address_data.json");

        string memory dataJson = vm.readFile(data);

        bytes memory encodedResult = json.parseRaw(
            string.concat(".", vm.toString(user1))
        );
        user.user = vm.parseJsonAddress(
            dataJson,
            string.concat(".", vm.toString(user1), ".Address")
        );
        user.id = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".ID")
        );
        user.amount = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".Amount")
        );
        result = abi.decode(encodedResult, (Result));
        console2.logBytes32(result.leaf);
    }

    function testClaimed() public {
        bool success = merkle.claim(
            user.user,
            user.id,
            user.amount,
            result.proof
        );
        assertTrue(success);
    }

    function testAlreadyClaimed() public {
        merkle.claim(user.user, user.id, user.amount, result.proof);
        vm.expectRevert("already claimed");
        merkle.claim(user.user, user.id, user.amount, result.proof);
    }

    function testIncorrectProof() public {
        bytes32[] memory fakeProofleaveitleaveit;

        vm.expectRevert("not whitelisted");
        merkle.claim(user.user, user.id, user.amount, fakeProofleaveitleaveit);
    }
}