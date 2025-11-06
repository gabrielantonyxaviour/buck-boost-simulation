import { useState, useEffect } from 'react';
import { Toaster, toast } from 'react-hot-toast';
import VaultDashboard from './components/VaultDashboard';
import {
  connectWallet,
  disconnectWallet,
  getWalletBalance,
  getVaultBalance,
  getVaultInfo,
  buildDepositTransaction,
  buildWithdrawTransaction,
  signAndSubmitTransaction,
} from './utils/stellar';

function App() {
  const [walletAddress, setWalletAddress] = useState<string | null>(null);
  const [walletBalance, setWalletBalance] = useState('0.00');
  const [vaultBalance, setVaultBalance] = useState('0.00');
  const [totalDeposits, setTotalDeposits] = useState('0.00');
  const [apy, setApy] = useState('5.00');
  const [isLoading, setIsLoading] = useState(false);

  const loadBalances = async (address: string) => {
    setIsLoading(true);
    try {
      const [wallet, vault, info] = await Promise.all([
        getWalletBalance(address),
        getVaultBalance(address),
        getVaultInfo(),
      ]);

      setWalletBalance(wallet);
      setVaultBalance(vault);
      setTotalDeposits(info.totalDeposits);
      setApy(info.apy);
    } catch (error) {
      console.error('Error loading balances:', error);
      toast.error('Failed to load balances');
    } finally {
      setIsLoading(false);
    }
  };

  const handleConnect = async () => {
    try {
      const address = await connectWallet();
      setWalletAddress(address);
      await loadBalances(address);
      toast.success('Wallet connected!');
    } catch (error) {
      console.error('Error connecting wallet:', error);
      toast.error('Failed to connect wallet');
    }
  };

  const handleDisconnect = () => {
    disconnectWallet();
    setWalletAddress(null);
    setWalletBalance('0.00');
    setVaultBalance('0.00');
    toast.success('Wallet disconnected');
  };

  const handleDeposit = async (amount: string) => {
    if (!walletAddress) return;

    setIsLoading(true);
    try {
      const xdr = await buildDepositTransaction(walletAddress, amount);
      await signAndSubmitTransaction(xdr);
      toast.success(`Successfully deposited ${amount} XLM!`);
      await loadBalances(walletAddress);
    } catch (error) {
      console.error('Error depositing:', error);
      toast.error('Deposit failed. Please try again.');
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const handleWithdraw = async (amount: string) => {
    if (!walletAddress) return;

    setIsLoading(true);
    try {
      const xdr = await buildWithdrawTransaction(walletAddress, amount);
      await signAndSubmitTransaction(xdr);
      toast.success(`Successfully withdrew ${amount} XLM!`);
      await loadBalances(walletAddress);
    } catch (error) {
      console.error('Error withdrawing:', error);
      toast.error('Withdrawal failed. Please try again.');
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const handleRefresh = async () => {
    if (walletAddress) {
      await loadBalances(walletAddress);
    }
  };

  return (
    <>
      <VaultDashboard
        walletAddress={walletAddress}
        isConnected={!!walletAddress}
        onConnect={handleConnect}
        onDisconnect={handleDisconnect}
        vaultBalance={vaultBalance}
        walletBalance={walletBalance}
        totalDeposits={totalDeposits}
        apy={apy}
        onDeposit={handleDeposit}
        onWithdraw={handleWithdraw}
        onRefresh={handleRefresh}
        isLoading={isLoading}
      />
      <Toaster
        position="bottom-right"
        toastOptions={{
          duration: 4000,
          style: {
            background: '#363636',
            color: '#fff',
          },
          success: {
            iconTheme: {
              primary: '#10b981',
              secondary: '#fff',
            },
          },
          error: {
            iconTheme: {
              primary: '#ef4444',
              secondary: '#fff',
            },
          },
        }}
      />
    </>
  );
}

export default App;
