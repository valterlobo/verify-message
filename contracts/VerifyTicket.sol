//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract VerifyTicket {
    struct Ticket {
        uint256 number;
        address owner;
        bytes32 code;
        bool used;
        uint256 usedAt;
    }

    mapping(uint256 => Ticket) private storageTickets;

    mapping(address => uint256[]) private myTicketsIds;

    using ECDSA for bytes32;
    using Counters for Counters.Counter;

    Counters.Counter private ticketIds;

    function getTicket() external returns (uint256) {
        ticketIds.increment();
        uint256 id = ticketIds.current() + 100;
        bytes32 code = keccak256(
            abi.encodePacked(block.difficulty, block.timestamp, id)
        );
        Ticket memory ticket = Ticket(id, msg.sender, code, false, 0);
        storageTickets[id] = ticket;
        myTicketsIds[msg.sender].push(id);
        return id;
    }

    function getMyTickets() external view returns (uint256[] memory) {
        return myTicketsIds[msg.sender];
    }

    //only admin or sender -security todo
    function getTicketInfo(uint256 id)
        external
        view
        returns (uint256, bytes32)
    {
        return (storageTickets[id].number, storageTickets[id].code);
    }

    function getMessageHash(bytes32 message, uint256 nonce)
        public
        view
        returns (bytes32)
    {
        address to = msg.sender;
        return keccak256(abi.encodePacked(to, message, nonce));
    }

    function verifyTicket(uint256 id) internal view returns (bool) {
        Ticket storage ticket = storageTickets[id];

        if (!(ticket.number == id && ticket.owner == msg.sender)) {
            return false;
        }
        return true;
    }

    function verifySignature(
        address signer,
        bytes32 message,
        uint256 nonce,
        bytes memory signature
    ) internal view returns (bool) {
        bytes32 messageHash = getMessageHash(message, nonce);
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();
        address receivedAddress = ECDSA.recover(
            ethSignedMessageHash,
            signature
        );
        return receivedAddress == signer;
    }

    function useTicket(
        uint256 id,
        bytes32 message,
        uint256 nonce,
        bytes memory signature
    ) external returns (bytes32) {
        Ticket storage ticket = storageTickets[id];
        if (
            verifyTicket(id) &&
            verifySignature(msg.sender, message, nonce, signature) &&
            !ticket.used
        ) {
            ticket.used = true;
            ticket.usedAt = block.timestamp;
            return ticket.code;
        } else {
            return "";
        }
    }
}
