import { ethers, run, network } from "hardhat";
import process from 'process';
import fs from 'fs';



async function main() {
  let isLocalNetwork: boolean = network.config.chainId == 31337
  const realIncomAccessControlFactory = await ethers.getContractFactory("RealIncomAccessControl");
  const realIncomAccessControlContract = await realIncomAccessControlFactory.deploy();
  await realIncomAccessControlContract.deployed();
  console.log("Contract Deployed to... Access Controls", realIncomAccessControlContract.address)
  if (!isLocalNetwork) {
    await realIncomAccessControlContract.deployTransaction.wait(6)

    await verify(realIncomAccessControlContract.address, [])
  }



  const realIncomNftFactory = await ethers.getContractFactory("RealIncomNft");
  const realIncomNftContract = await realIncomNftFactory.deploy(realIncomAccessControlContract.address);
  await realIncomNftContract.deployed();
  console.log("Contract Deployed to... NFT", realIncomNftContract.address)
  if (!isLocalNetwork) {
    await realIncomNftContract.deployTransaction.wait(6)

    await verify(realIncomNftContract.address, [realIncomAccessControlContract.address])
  }

  const realIncomAuctionFactory = await ethers.getContractFactory("RealIncomAuction");
  const realIncomAuctionContract = await realIncomAuctionFactory.deploy(realIncomNftContract.address, realIncomAccessControlContract.address);
  await realIncomAuctionContract.deployed();
  console.log("Contract Deployed to... Auction", realIncomAuctionContract.address)
  if (!isLocalNetwork) {
    await realIncomAuctionContract.deployTransaction.wait(6)

    await verify(realIncomAuctionContract.address, [realIncomNftContract.address, realIncomAccessControlContract.address])
  }


  // const realIncomAuctionFactory = await ethers.getContractFactory("RealIncomAuction");
  // const realIncomAuctionContract = await realIncomAuctionFactory.deploy("0xd54765ccB13FDeb047276E2F85AF75B99680Ba23", "0x93353507af4eD824E95D0fe57BeA183f7C218e59");
  // await realIncomAuctionContract.deployed();
  // console.log("Contract Deployed to... Auction", realIncomAuctionContract.address)
  // if (!isLocalNetwork) {
  //   await realIncomAuctionContract.deployTransaction.wait(6)

  //   await verify(realIncomAuctionContract.address, ["0xd54765ccB13FDeb047276E2F85AF75B99680Ba23", "0x93353507af4eD824E95D0fe57BeA183f7C218e59"])
  // }

  const villageSquareFactory = await ethers.getContractFactory("VillageSquare");
  const villageSquareContract = await villageSquareFactory.deploy(realIncomAuctionContract.address, realIncomAccessControlContract.address);
  await villageSquareContract.deployed();
  console.log("Contract Deployed to... Village Square", villageSquareContract.address)
  if (!isLocalNetwork) {
    await villageSquareContract.deployTransaction.wait(6)

    await verify(villageSquareContract.address, [realIncomAuctionContract.address, realIncomAccessControlContract.address])
  }

  const RealIncomLoanFactory = await ethers.getContractFactory("RealIncomLoan");
  const RealIncomLoanContract = await RealIncomLoanFactory.deploy(realIncomNftContract.address, realIncomAccessControlContract.address);
  await RealIncomLoanContract.deployed();
  console.log("Contract Deployed to... Real Incom Loan", RealIncomLoanContract.address)
  if (!isLocalNetwork) {
    await RealIncomLoanContract.deployTransaction.wait(6)

    await verify(RealIncomLoanContract.address, [realIncomNftContract.address, realIncomAccessControlContract.address])
  }

  const addressManagerFactory = await ethers.getContractFactory("AddressManager");
  const addressManagerContract = await addressManagerFactory.deploy(realIncomAccessControlContract.address, realIncomAuctionContract.address, realIncomNftContract.address, villageSquareContract.address, RealIncomLoanContract.address);
  await addressManagerContract.deployed();
  console.log("Contract Deployed to... Address Manager", addressManagerContract.address)
  if (!isLocalNetwork) {
    await addressManagerContract.deployTransaction.wait(6)

    await verify(addressManagerContract.address, [realIncomAccessControlContract.address, realIncomAuctionContract.address, realIncomNftContract.address, villageSquareContract.address, RealIncomLoanContract.address])
  }


 

  let addressChangeTxn = await realIncomAccessControlContract.updateAddressManager(addressManagerContract.address)
  console.log("updating address manager on access control contract...")
  await addressChangeTxn.wait(1)
  let newAddressManagerAddress = await realIncomAccessControlContract.addressManager()
  console.log("Address updated to ...", newAddressManagerAddress)

  fs.writeFileSync("addresses.json", JSON.stringify({
    "Access Controls": realIncomAccessControlContract.address,
    "NFT": realIncomNftContract.address,
    "Auction": realIncomAuctionContract.address,
    "Village Square": villageSquareContract.address,
    "Address Manager": addressManagerContract.address,
    "Loan": RealIncomLoanContract.address

  }))

  console.log({
    "Access Controls": realIncomAccessControlContract.address,
    "NFT": realIncomNftContract.address,
    "Auction": realIncomAuctionContract.address,
    "Village Square": villageSquareContract.address,
    "Address Manager": addressManagerContract.address,
    "Loan": RealIncomLoanContract.address


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