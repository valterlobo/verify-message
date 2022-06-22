// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
// node
const EthCrypto = require('eth-crypto');

async function main() {

    console.log("crypt");
    const identity = EthCrypto.createIdentity();

    const encrypted = await EthCrypto.encryptWithPublicKey(
        identity.publicKey, // publicKey
        'foobar coco esta merda decrypt' // message
    );
    console.log(encrypted);
    const str = EthCrypto.cipher.stringify(encrypted);
    const message = await EthCrypto.decryptWithPrivateKey(
        identity.privateKey, // privateKey
        str // encrypted-data
    );

    console.log(message);


}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});