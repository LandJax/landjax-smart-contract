import { ethers, run } from "hardhat";
import process from 'process';



async function main() {
  const realIncomAccessControlFactory = await ethers.getContractFactory("RealIncomAccessControl");
  const realIncomAccessControlContract = await realIncomAccessControlFactory.deploy();
  await realIncomAccessControlContract.deployed();
  await realIncomAccessControlContract.deployTransaction.wait(6)
  await verify(realIncomAccessControlContract.address, [])

  const realIncomNftFactory = await ethers.getContractFactory("RealIncomNft");
  const realIncomNftContract = await realIncomNftFactory.deploy(realIncomAccessControlContract.address);
  await realIncomNftContract.deployed();
  await realIncomNftContract.deployTransaction.wait(6)
  await verify(realIncomNftContract.address, [])

  const realIncomAuctionFactory = await ethers.getContractFactory("RealIncomAuction");
  const realIncomAuctionContract = await realIncomAuctionFactory.deploy(realIncomNftContract.address,realIncomAccessControlContract.address);
  await realIncomAuctionContract.deployed();
  await realIncomAuctionContract.deployTransaction.wait(6)
  await verify(realIncomAuctionContract.address, [])

  const villageSquareFactory = await ethers.getContractFactory("VillageSquare");
  const villageSquareContract = await villageSquareFactory.deploy(realIncomAuctionContract.address, realIncomAccessControlContract.address);
  await villageSquareContract.deployed();
  await villageSquareContract.deployTransaction.wait(6)
  await verify(villageSquareContract.address, [])
}

const verify = async (contractAddress:string, args: any) => {
  console.log("Verifying contract...")
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    })
  } catch (e) {
    if (e instanceof Error){
      if (e.message.toLowerCase().includes("already verified")) {
        console.log("Already Verified!")
      } else {
        console.log(e)
      }
    }
    }
   
}



main().then(()=> {
  process.exit(1);
}).catch(err => {
  console.log(err);
  process.exit(0);
})