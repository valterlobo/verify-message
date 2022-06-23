# POC Verification of signature and verification of ownership for access (ticket) [Solidity]

##  Verify Ticket
@startuml

' -- classes --


class VerifyTicket {
    ' -- inheritance --

    ' -- usingFor --
	{abstract}📚ECDSA for [[bytes32]]
	{abstract}📚Counters for [[Counters.Counter]]

    ' -- vars --
	-[[mapping uint256=>Ticket ]] storageTickets
	-[[mapping address=>null ]] myTicketsIds
	-[[Counters.Counter]] ticketIds

    ' -- methods --
	+getTicket()
	+🔍getMyTickets()
	+🔍getTicketInfo()
	+🔍getMessageHash()
	#🔍verifyTicket()
	#🔍verifySignature()
	+useTicket()

}
' -- inheritance / usingFor --
VerifyTicket ..[#DarkOliveGreen]|> ECDSA : //for bytes32//
VerifyTicket ..[#DarkOliveGreen]|> Counters : //for Counters.Counter//

@enduml


##  Verify signature

@startuml

' -- classes --


class VerifySignature {
    ' -- inheritance --

    ' -- usingFor --
	{abstract}📚ECDSA for [[bytes32]]

    ' -- vars --

    ' -- methods --
	+🔍getMessageHash()
	+🔍getEthSignedMessageHash()
	+🔍verify()
	+🔍recoverSigner()

}
' -- inheritance / usingFor --
VerifySignature ..[#DarkOliveGreen]|> ECDSA : //for bytes32//

@enduml

## Hardhat tasks 

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.js
node scripts/deploy.js
npx eslint '**/*.js'
npx eslint '**/*.js' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```
