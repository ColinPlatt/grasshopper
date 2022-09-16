Grasshopper - Moving factory architecture 


Motivation:
Censorship resistance is a core motivation behind using blockchains and Ethereum. Recent actions by regulatory bodies have demonstrated that, despite the distributed nature of Ethereum and Ethereum based networks, censorship is still a concern. The ability to pinpoint specific resting addresses with undesirable features, and potentially enforce real world retalitory measures on wallets, addresses and tokens that interact with or pass through these addresses proves that the current pattern may not be sufficient for all use cases. 

Grasshopper introduces the concept of iterative, or moving factory contracts, which allow for the core onchain components of a contract and its assets to move with every interaction. 

The normal factory/instance and clone factory "minimal proxy" (EIP-1167) patterns use a deployed instance (Foundation or factory) at a fixed address that is called and which implements a contract to a new address. This means that while an instance can be redeployed as necessary to thwart attempts to censor an individual instance by address, the base factory itself remains a static and easy to identify target for censorship. This also shifts responsbility from users, who may or may not be engaged in actions seen as undesirable, to the deployers of the original or onward deployments.

Grasshopper changes this pattern by using a modified factory/instance pattern following each interaction. This means that a factory has the life of one interaction, afterwhich previous factories are discarded or abandoned. 

Regulatory bodies seeking to censor Grasshopper deployments can only identify previous, abandoned addresses, and the current location which will only exist until its next called, making the cost of censorhip orders of magnitudes higher than with traditional fixed address pattern.

For the ETHBerlin Hackathon (2022), we demonstrate the Grasshopper technique on a simplified Tornado Cash contract, Grasshopper Cash (GC). 

GC allows a user to create a receipt with an offchain generated secret, and pass a hash of that secret to the latest address GC along with a deposit (1 ETH), and the image of the deployment factory (which can be saved onchain and/or offchain). This action generates a CREATE2 transaction using the hash of the user's secret as the salt for the next deployment, thereby creating a tree of all previous contracts which can be calculated and followed from the deployment of GC upto the current location. Withdrawals work in a similar manner, modifying the tree to remove the user's deposit from the tree so that it cannot be double spent. 


Benchmark gas usage for Tornado (1 ETH):

Deposit - 885k
Withdrawal - 327k


To think about:
[ ] ensuring privacy and link breaking between deposit and withdrawl
[ ] ensuring merkletree cannot be gamed
[ ] gas usage
[ ] finding the latest deployment
[ ] UI and hash generation