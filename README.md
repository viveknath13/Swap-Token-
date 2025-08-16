 # Token Swap 
 The TokenSwap.sol contract is a decentralized exchange (DEX) that allows
   users to trade VivekToken and BobToken. It uses an automated market
  maker (AMM) system to determine the price of the tokens and facilitate
  swaps. This means that instead of relying on a traditional order book,
  the contract uses a liquidity pool and a mathematical formula to execute
   trades.

  Core Concepts

   * Liquidity Pool: The contract maintains a pool of both VivekToken and
     BobToken, which is funded by users who provide liquidity.
   * Constant Product Formula: The contract uses the formula x * y = k to
     determine the price of the tokens, where:
       * x is the amount of VivekToken in the liquidity pool.
       * y is the amount of BobToken in the liquidity pool.
       * k is a constant value that must remain the same after each trade.

  Functions Explained

  constructor(address _VivekToken, address _BobToken)

   * This function is called when the contract is deployed.
   * It initializes the contract with the addresses of the VivekToken and
     BobToken contracts.
   * It includes a check to ensure that neither of the token addresses is
     the zero address.

  addLiquidity(uint256 _amount)

   * This function allows users to add liquidity to the exchange.
   * To add liquidity, a user must deposit an equal amount of both
     VivekToken and BobToken.
   * The contract then updates the user's share of the liquidity pool and
     the total liquidity in the pool.
   * The user's liquidity is tracked in the s_balances mapping.

  removeLiquidity(uint256 _amount)

   * This function allows users to withdraw their liquidity from the
     exchange.
   * A user can withdraw up to the amount of liquidity they have provided.
   * When a user withdraws liquidity, the contract sends them their share
     of both VivekToken and BobToken.
   * The user's liquidity balance and the total liquidity in the pool are
     updated accordingly.

  swap(address _token, uint256 amount)

   * This is the core function of the exchange, allowing users to swap one
      token for another.
   * When a user wants to swap tokens, they call this function with the
     address of the token they want to sell and the amount.
   * The contract calculates the amount of the other token to return to
     the user based on the constant product formula.
   * The contract then transfers the input token from the user to itself
     and sends the output token to the user.

  Getter Functions

   * getTotalAmount(): Returns the total amount of liquidity in the
     exchange.
   * getBalance(address account): Returns the amount of liquidity a
     specific user has provided.
   * getTokenBalances(): Returns the current balance of both VivekToken
     and BobToken held by the contract.
     deployed on rootstock https://explorer.testnet.rootstock.io/address/0x4bc72a312ddd3752fdbfb17ca041c4bd110a7249
