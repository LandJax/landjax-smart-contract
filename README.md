### TITLE: RealIncom Subgraph: An NFT Digital Marketplace for All Digital asset with income generation Capability

#### DESCRIPTION:
RealIncom is an NFT market for digital assets, In this marketplace Digital asset owners can collaborate with artists, to create an NFT with an interesting art side, and a digital asset with hourly, daily, monthly, quaterly or yearly income capabilities. Users can also breed NFT's  called Digi's with Similar NFT's to create a Unique breed that can be minted for a new Listing.

### LIVE PROJECT URL: https://www.realincom.com/

#### TABLE OF CONTENT:
#### Smart Contracts


#### Subgraph
###### Entities:
- DigiSale
    contains entities that are actively on auction
- Dispute
    contains Auctions to be resolved and those that are already resolved this part indexes the VillageSquare contract were disputes are settled, this was designed so that in the case where auction ends and nft isn't deliverred or funds aren't released.
- Digi
    Digi is what i call the nft Digi asset contains information below:
        Dispute
        Digi
        Loan
        Borrowed
        owner
        e.t.c
- Loan
    the loan Entity contains all the information about a created loan
    the loaner creates a loan which is put on the loan market place, A user or merchant seeking a loan can now apply for this loan and is only allowed to do so if they have an NFT collateral.

- Borrowed
    contains all the entities that borrowed funds(Matic for now, add support for more currencies in the future) tied to a particular loan, in essence the borrowed will appear under borrowedLoans field.
- User
    A user is an entity that performs any of those interaction.
###### Mappers:

- real-incom-auction
    Maps to DigiSale, Digi, and users

- real-incom-nft
    only maps to digi and users mostly when transfer events or nftminted is emitted from the smart contract.

#### Frontend



#### HOW TO INSTALL AND RUN THIS PROJECT:

##### SUBGRAPH
- 1. clone this repo "git clone https://github.com/Fischela-Organization/realincom-subgraph.git"
- pre - run "yarn"
- 2. run => "yarn codegen && yarn build"
- 3. authenticate your graph "graph auth --product hosted-service <ACCESS_TOKEN>"
- 4.  you can deploy with this command "graph deploy --product hosted-service <GITHUB_USER>/<SUBGRAPH NAME>"
- 5 Replace your <ACCESS_TOKEN>, <GITHUB_USER>, <SUBGRAPH NAME> respectively

##### SMART CONTRACT
- 1. clone this repo "git clone https://github.com/Fischela-Organization/real-income-smartcontract.git"
- 2. run => "yarn"
- 3. to compile run "yarn hardhat compile"
- 4. to deploy to local run "yarn hardhat run scripts/deploy.ts"
- 5. Deploy to polygon with the command "arn hardhat run scripts/deploy.ts --network matic"
- 6. Contract addresses of the six contracts would be written to /addresses.json

##### FRONTEND(NEXTJS)
- 1. clone this repo "git clone  https://github.com/Fischela-Organization/real-incom-frontend.git"
- 2. run => "yarn"
- 3. run => "npm run dev or yarn dev" to start developement server
- 4. if you are deploying to another chain other than polygon replace the contract addresses and abis in the /Artifacts Directory
- 5. create a .env file and add keys from env.example get an access token from https://web3.storage and subgraphs graphql client URI from https://thegraph.com/hosted-service/subgraph/norvirae/realincom-subgraph
- 6. you are good to go

#### HOW TO USE THIS PROJECT:
###### Frontend
The NFT marketplace Auction Features(Mint Digital asset, start auction, place a bid, cancel auction, result auction, confirm results) features have been hooked to the frontend and the UI's to call this functions are ready with error handlers

###### Smart contract
you can test out other smart contract features here at the address manager (<a href="https://mumbai.polygonscan.com/address/0xB5c2b379d7C397B617B91367D2e8396274B4ebC8#writeContract">Smart contract address manager</a>) you can navigate to the read section, the contract addresses of (Auction, accesscontrols, village square, loan, nft) contract to get a feel of the backend build.

I and my team would make it functional within a short time.

###### Subgraph
You can play around with realincom data on thegraph protocol from here: https://thegraph.com/hosted-service/subgraph/norvirae/realincom-subgraph

You can also consume from your graphql frontend application with client ID: https://api.thegraph.com/subgraphs/name/norvirae/realincom-subgraph

#### FUTURE INTEGRATIONS
- implement Loan marketplace(Frontend)
- Implement Disputes(Frontend)
- Implement Breeding system with spines-ts
- Add KYC support
- Strengthen smart contract security reintroduce re-entrancy guard and more bug hunting and code auditing
- Launch to mainnet
- Start entertaining real actual users.
- Introduce 2.5% percentage cut for every nft purchased and loan paid back to loaner


#### HOW TO CONTRIBUTE TO THE PROJECT:
send me an email: norbertmbafrank@gmail.com or chat me on whatsapp: +2347025488825
follow realincom on instagram: https://www.instagram.com/realincomagency
see live project: https://www.realincom.com


#### CREDITS:
    credits to chrisstef at https://github.com/chrisstef for the base react frontend which I converted to a typescript nextjs project for SEO purposes. 

#### What was your motivation?

RealIncom was born out of the need to solve the issue of Non Fungible Tokens Valuation, The issue of : "Is an NFT really worth it"

OpenSea is the world’s most popular NFT marketplace.
It was recently valued at over $13 billion after a new funding round raised $300 million.
Looking at the data, there is a clear uptrend in daily NFT trading volume up until the end of January where it forms a peak.
Since then, trading volume has remained in a downtrend, now averaging around $70 million daily.
This means that looking at this metric alone, NFT trading activity has declined by over 70% a bubble burst?

A 70% decline in Trading volume really means that truly Traders are beginning to realize that the prospect was a bubble, the NFT's being purchased by prospective traders are really just liabilities with a hyped price, and every holder just wants to get the NFT of there hands to make fast profit, the end holder takes the loss.

#### The Reason for building this project?

I Built this project to solve the problem of NFT's valuation and the collateralization problem where Decentralised Loaning is risky for prospective loaners due to lack of credible collateral for loan(trust issue)
Digital assets tied to NFT's can be used as collateral.
Aave solved this problem by allowing users to exploit arbitrage opportunties, but users or debtors would have to borrow and payback with interest in 
on transaction, so in theory user doesn't hold the loan for morethan a few seconds. This is quite efficient for fungible tokens and exchanges.
but what if a user would want to actually invest the money and make gains off the internet(Invest in real estate, agriculture e.t.c)

#### What problem are we solving?
It simply tied NFT's to real value that generates passive or active income, that can in turn be used for decentralised collateral for loans.

#### What makes this project stand out?
From my research this project is the first in the web3 space that tries to solve a problem in this way, collateralizing digital assets with real value tied to NFT's with income generation.

