import { ethers, run, network } from "hardhat";
import process from 'process';
import fs from 'fs';



async function main() {
  let isLocalNetwork: boolean = network.config.chainId == 31337
  const landjaxAccessControlFactory = await ethers.getContractFactory("LandjaxAccessControl");
  const landjaxAccessControlContract = await landjaxAccessControlFactory.deploy();
  await landjaxAccessControlContract.deployed();
  console.log("Contract Deployed to... Access Controls", landjaxAccessControlContract.address)
  if (!isLocalNetwork) {
    await landjaxAccessControlContract.deployTransaction.wait(6)

    await verify(landjaxAccessControlContract.address, [])
  }



  const landjaxNftFactory = await ethers.getContractFactory("LandjaxNft");
  const landjaxNftContract = await landjaxNftFactory.deploy(landjaxAccessControlContract.address);
  await landjaxNftContract.deployed();
  console.log("Contract Deployed to... NFT", landjaxNftContract.address)
  if (!isLocalNetwork) {
    await landjaxNftContract.deployTransaction.wait(6)

    await verify(landjaxNftContract.address, [landjaxAccessControlContract.address])
  }

  const landjaxAuctionFactory = await ethers.getContractFactory("LandjaxAuction");
  const landjaxAuctionContract = await landjaxAuctionFactory.deploy(landjaxNftContract.address, landjaxAccessControlContract.address);
  await landjaxAuctionContract.deployed();
  console.log("Contract Deployed to... Auction", landjaxAuctionContract.address)
  if (!isLocalNetwork) {
    await landjaxAuctionContract.deployTransaction.wait(6)

    await verify(landjaxAuctionContract.address, [landjaxNftContract.address, landjaxAccessControlContract.address])
  }

  // Single Begin

  // const landjaxNftFactory = await ethers.getContractFactory("LandjaxNft");
  // const landjaxNftContract = await landjaxNftFactory.deploy("0x93353507af4eD824E95D0fe57BeA183f7C218e59");
  // await landjaxNftContract.deployed();
  // console.log("Contract Deployed to... NFT", landjaxNftContract.address)
  // if (!isLocalNetwork) {
  //   await landjaxNftContract.deployTransaction.wait(6)

  //   await verify(landjaxNftContract.address, ["0x93353507af4eD824E95D0fe57BeA183f7C218e59"])
  // }


  // const landjaxAuctionFactory = await ethers.getContractFactory("LandjaxAuction");
  // const landjaxAuctionContract = await landjaxAuctionFactory.deploy(landjaxNftContract.address, "0x93353507af4eD824E95D0fe57BeA183f7C218e59");
  // await landjaxAuctionContract.deployed();
  // console.log("Contract Deployed to... Auction", landjaxAuctionContract.address)
  // if (!isLocalNetwork) {
  //   await landjaxAuctionContract.deployTransaction.wait(6)

  //   await verify(landjaxAuctionContract.address, [landjaxNftContract.address, "0x93353507af4eD824E95D0fe57BeA183f7C218e59"])
  // }

  // single end

  const villageSquareFactory = await ethers.getContractFactory("VillageSquare");
  const villageSquareContract = await villageSquareFactory.deploy(landjaxAuctionContract.address, landjaxAccessControlContract.address);
  await villageSquareContract.deployed();
  console.log("Contract Deployed to... Village Square", villageSquareContract.address)
  if (!isLocalNetwork) {
    await villageSquareContract.deployTransaction.wait(6)

    await verify(villageSquareContract.address, [landjaxAuctionContract.address, landjaxAccessControlContract.address])
  }

  const landjaxLoanFactory = await ethers.getContractFactory("LandjaxLoan");
  const landjaxLoanContract = await landjaxLoanFactory.deploy(landjaxNftContract.address, landjaxAccessControlContract.address);
  await landjaxLoanContract.deployed();
  console.log("Contract Deployed to... Real Incom Loan", landjaxLoanContract.address)
  if (!isLocalNetwork) {
    await landjaxLoanContract.deployTransaction.wait(6)

    await verify(landjaxLoanContract.address, [landjaxNftContract.address, landjaxAccessControlContract.address])
  }

  const addressManagerFactory = await ethers.getContractFactory("AddressManager");
  const addressManagerContract = await addressManagerFactory.deploy(landjaxAccessControlContract.address, landjaxAuctionContract.address, landjaxNftContract.address, villageSquareContract.address, landjaxLoanContract.address);
  await addressManagerContract.deployed();
  console.log("Contract Deployed to... Address Manager", addressManagerContract.address)
  if (!isLocalNetwork) {
    await addressManagerContract.deployTransaction.wait(6)

    await verify(addressManagerContract.address, [landjaxAccessControlContract.address, landjaxAuctionContract.address, landjaxNftContract.address, villageSquareContract.address, landjaxLoanContract.address])
  }


 

  let addressChangeTxn = await landjaxAccessControlContract.updateAddressManager(addressManagerContract.address)
  console.log("updating address manager on access control contract...")
  await addressChangeTxn.wait(1)
  let newAddressManagerAddress = await landjaxAccessControlContract.addressManager()
  console.log("Address updated to ...", newAddressManagerAddress)

  fs.writeFileSync("addresses.json", JSON.stringify({
    "Access Controls": landjaxAccessControlContract.address,
    "NFT": landjaxNftContract.address,
    "Auction": landjaxAuctionContract.address,
    "Village Square": villageSquareContract.address,
    "Address Manager": addressManagerContract.address,
    "Loan": landjaxLoanContract.address

  }))

  console.log({
    // "Access Controls": landjaxAccessControlContract.address,
    "NFT": landjaxNftContract.address,
    "Auction": landjaxAuctionContract.address,
    // "Village Square": villageSquareContract.address,
    // "Address Manager": addressManagerContract.address,
    // "Loan": landjaxLoanContract.address


  })

}

const verify = async (contractAddress: string, args: any) => {
  console.log("Verifying contract...")
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    })

  } catch (e) {
    if (e instanceof Error) {
      if (e.message.toLowerCase().includes("already verified")) {
        console.log("Already Verified!")
      } else {
        console.log(e)
      }
    }
  }

}


main().then(() => {
  process.exit(0);
}).catch(err => {
  console.log(err);
  process.exit(1);
})