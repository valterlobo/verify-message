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

    myTicketsID.forEach(async (id) => {
      console.log(id);

      const resultTicket = await contract.connect(signer).getTicketInfo(id);

      // verify
      const idTicket = resultTicket[0];
      const message = resultTicket[1];
      const nonce = Math.floor(Math.random() * idTicket.value);
      const hash = await contract
        .connect(signer)
        .getMessageHash(message, nonce);
      const sig = await signer.signMessage(ethers.utils.arrayify(hash));

      // use ticket
      const tx = await contract
        .connect(signer)
        .useTicket(idTicket, message, nonce, sig);
    });
  });
});
