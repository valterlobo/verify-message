//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
   0 - A pessoa obtem um ticket. 

   1 - a pessoa apresenta o ticket e o seu endereço publico e assina uma mensagem. 

   2-  o verificador  verifica se o ticket pertence ao endereço e assina uma mensagem 
   com o endereço. 

   3 - a pessoa recebe a mensagem enviada e realiza discritografa a mensagem . 

   4 - O verificador recebe a mensagem e compara com a mensagem enviada - se estiver ok true senao false. 

    

 */
contract VerifyTicket {

    struct Ticket {
        uint256 number;
        address owner;
        bytes32 code;
        bool used;
    }

    mapping(address => Ticket) private tickets;

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
        Ticket memory ticket = Ticket(id, msg.sender, code, false);
        console.log(id);
        tickets[msg.sender] = ticket;
        storageTickets[id] = ticket;
        myTicketsIds[msg.sender].push(id);
        return id;
    }

    function getMyTickets() external view returns (uint256[] memory) {
        return myTicketsIds[msg.sender];
    }


        //only admin or sender -security 
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
        Ticket storage ticket = tickets[msg.sender];

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
        console.log("ADDR", receivedAddress, signer);
        return receivedAddress == signer;
    }

    function useTicket(
        uint256 id,
        bytes32 message,
        uint256 nonce,
        bytes memory signature
    ) external returns (bytes32) {
        Ticket storage ticket = tickets[msg.sender];
        if (
            verifyTicket(id) &&
            verifySignature(msg.sender, message, nonce, signature) &&
            !ticket.used
        ) {
            ticket.used = true;
            //ticket.used = true; set used off-chain the code enter.
            //console.log(ticket.code);
            return ticket.code; //ticket.code;
        } else {
            return "";
        }
    }

    function getTicketCode(
        uint256 id,
        uint256 nonce,
        bytes32 message,
        bytes memory signature
    ) external view returns (bytes32) {
        if (verifySignature(msg.sender, message, nonce, signature)) {
            Ticket storage ticket = tickets[msg.sender];

            return ticket.code;
        } else {
            return "";
        }
    }
}
