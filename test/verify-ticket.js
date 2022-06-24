const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VerifySecret", function () {
  it("Check secret", async function () {
    const accounts = await ethers.getSigners();

    const Verify = await ethers.getContractFactory("VerifyTicket");
    const contract = await Verify.deploy();
    await contract.deployed();

    const signer = accounts[0];
    // buy a tickets
    for (let i = 0; i < 10; i++) {
      await contract.connect(signer).getTicket();
    }

    // get my tickets
    const myTicketsID = await contract.connect(signer).getMyTickets();

    // test array length - qtd tikckets
    expect(myTicketsID.length).to.equal(10);

    await Promise.all(
      myTicketsID.map(async (id) => {
        const resultTicket = await contract.connect(signer).getTicketInfo(id);

        // verify
        const idTicket = resultTicket[0];
        const message = resultTicket[1];
        const n = parseInt(idTicket);
        const nonce = Math.floor(Math.random() * n);
        const hash = await contract
          .connect(signer)
          .getMessageHash(message, nonce);
        // console.log(hash);
        const sig = signer.signMessage(ethers.utils.arrayify(hash));

        // use ticket
        await contract.connect(signer).useTicket(idTicket, message, nonce, sig);

        const resultUsedTicket = await contract
          .connect(signer)
          .getTicketInfo(id);
        // console.log(resultUsedTicket);
        // console.log(message);

        // test  used ticket
        expect(resultUsedTicket[2]).to.equal(true);
        // test  code ticket
        expect(resultUsedTicket[1]).to.equal(message);

        // console.log("FIM");
      })
    );
  });
});
