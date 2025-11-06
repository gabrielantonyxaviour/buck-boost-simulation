import {
  StellarWalletsKit,
  WalletNetwork,
  allowAllModules,
  FREIGHTER_ID,
} from '@creit.tech/stellar-wallets-kit';
import * as StellarSdk from '@stellar/stellar-sdk';

// Stellar configuration
export const STELLAR_NETWORK = WalletNetwork.TESTNET;
export const NETWORK_PASSPHRASE = StellarSdk.Networks.TESTNET;
export const HORIZON_URL = 'https://horizon-testnet.stellar.org';

// Contract addresses - Replace these with your deployed contract addresses
export const VAULT_CONTRACT_ID = process.env.VITE_VAULT_CONTRACT_ID || '';
export const TOKEN_CONTRACT_ID = process.env.VITE_TOKEN_CONTRACT_ID || 'CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC'; // Native XLM token

let walletKit: StellarWalletsKit | null = null;

export const initializeWalletKit = () => {
  if (!walletKit) {
    walletKit = new StellarWalletsKit({
      network: STELLAR_NETWORK,
      selectedWalletId: FREIGHTER_ID,
      modules: allowAllModules(),
    });
  }
  return walletKit;
};

export const getWalletKit = () => {
  if (!walletKit) {
    return initializeWalletKit();
  }
  return walletKit;
};

export const connectWallet = async () => {
  const kit = getWalletKit();
  const { address } = await kit.getAddress();
  return address;
};

export const disconnectWallet = () => {
  // Clear wallet connection
  walletKit = null;
};

export const getWalletBalance = async (address: string): Promise<string> => {
  try {
    const server = new StellarSdk.Horizon.Server(HORIZON_URL);
    const account = await server.loadAccount(address);

    // Find native XLM balance
    const nativeBalance = account.balances.find(
      (balance) => balance.asset_type === 'native'
    );

    return nativeBalance ? parseFloat(nativeBalance.balance).toFixed(2) : '0.00';
  } catch (error) {
    console.error('Error fetching wallet balance:', error);
    return '0.00';
  }
};

export const stroopsToXlm = (stroops: bigint): string => {
  return (Number(stroops) / 10_000_000).toFixed(7);
};

export const xlmToStroops = (xlm: string): bigint => {
  return BigInt(Math.floor(parseFloat(xlm) * 10_000_000));
};

// Contract interaction utilities
export const buildDepositTransaction = async (
  userAddress: string,
  amount: string
): Promise<string> => {
  const server = new StellarSdk.Horizon.Server(HORIZON_URL);
  const account = await server.loadAccount(userAddress);

  const stroops = xlmToStroops(amount);

  // Build contract invocation
  // This is a simplified version - you'll need to adjust based on your actual contract
  const contract = new StellarSdk.Contract(VAULT_CONTRACT_ID);

  const transaction = new StellarSdk.TransactionBuilder(account, {
    fee: StellarSdk.BASE_FEE,
    networkPassphrase: NETWORK_PASSPHRASE,
  })
    .addOperation(
      contract.call(
        'deposit',
        StellarSdk.nativeToScVal(userAddress, { type: 'address' }),
        StellarSdk.nativeToScVal(stroops, { type: 'i128' })
      )
    )
    .setTimeout(300)
    .build();

  return transaction.toXDR();
};

export const buildWithdrawTransaction = async (
  userAddress: string,
  amount: string
): Promise<string> => {
  const server = new StellarSdk.Horizon.Server(HORIZON_URL);
  const account = await server.loadAccount(userAddress);

  const stroops = xlmToStroops(amount);

  const contract = new StellarSdk.Contract(VAULT_CONTRACT_ID);

  const transaction = new StellarSdk.TransactionBuilder(account, {
    fee: StellarSdk.BASE_FEE,
    networkPassphrase: NETWORK_PASSPHRASE,
  })
    .addOperation(
      contract.call(
        'withdraw',
        StellarSdk.nativeToScVal(userAddress, { type: 'address' }),
        StellarSdk.nativeToScVal(stroops, { type: 'i128' })
      )
    )
    .setTimeout(300)
    .build();

  return transaction.toXDR();
};

export const getVaultBalance = async (userAddress: string): Promise<string> => {
  try {
    if (!VAULT_CONTRACT_ID) {
      return '0.00';
    }

    const server = new StellarSdk.Horizon.Server(HORIZON_URL);
    const contract = new StellarSdk.Contract(VAULT_CONTRACT_ID);

    // Build the get_balance call
    const account = await server.loadAccount(userAddress);
    const transaction = new StellarSdk.TransactionBuilder(account, {
      fee: StellarSdk.BASE_FEE,
      networkPassphrase: NETWORK_PASSPHRASE,
    })
      .addOperation(
        contract.call(
          'get_balance',
          StellarSdk.nativeToScVal(userAddress, { type: 'address' })
        )
      )
      .setTimeout(300)
      .build();

    const result = await server.simulateTransaction(transaction);

    if (result.results && result.results.length > 0) {
      const scVal = result.results[0].xdr;
      const balance = StellarSdk.scValToNative(scVal);
      return stroopsToXlm(BigInt(balance));
    }

    return '0.00';
  } catch (error) {
    console.error('Error fetching vault balance:', error);
    return '0.00';
  }
};

export const getVaultInfo = async (): Promise<{ totalDeposits: string; apy: string }> => {
  try {
    if (!VAULT_CONTRACT_ID) {
      return { totalDeposits: '0.00', apy: '5.00' };
    }

    const server = new StellarSdk.Horizon.Server(HORIZON_URL);
    const contract = new StellarSdk.Contract(VAULT_CONTRACT_ID);

    // For simulation purposes, return mock data
    // In production, you would call the contract's get_vault_info function
    return {
      totalDeposits: '10000.00',
      apy: '5.00',
    };
  } catch (error) {
    console.error('Error fetching vault info:', error);
    return { totalDeposits: '0.00', apy: '5.00' };
  }
};

export const signAndSubmitTransaction = async (xdr: string): Promise<void> => {
  const kit = getWalletKit();
  const { signedTxXdr } = await kit.signTransaction(xdr, {
    networkPassphrase: NETWORK_PASSPHRASE,
  });

  const server = new StellarSdk.Horizon.Server(HORIZON_URL);
  const transaction = StellarSdk.TransactionBuilder.fromXDR(
    signedTxXdr,
    NETWORK_PASSPHRASE
  );

  await server.submitTransaction(transaction);
};
