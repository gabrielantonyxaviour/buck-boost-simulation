import React, { useState, useEffect } from 'react';
import { ArrowDownCircle, ArrowUpCircle, Wallet, RefreshCw } from 'lucide-react';
import VaultCard from './VaultCard';
import DepositModal from './DepositModal';
import WithdrawModal from './WithdrawModal';
import toast from 'react-hot-toast';

interface VaultDashboardProps {
  walletAddress: string | null;
  isConnected: boolean;
  onConnect: () => void;
  onDisconnect: () => void;
  vaultBalance: string;
  walletBalance: string;
  totalDeposits: string;
  apy: string;
  onDeposit: (amount: string) => Promise<void>;
  onWithdraw: (amount: string) => Promise<void>;
  onRefresh: () => Promise<void>;
  isLoading?: boolean;
}

const VaultDashboard: React.FC<VaultDashboardProps> = ({
  walletAddress,
  isConnected,
  onConnect,
  onDisconnect,
  vaultBalance,
  walletBalance,
  totalDeposits,
  apy,
  onDeposit,
  onWithdraw,
  onRefresh,
  isLoading = false,
}) => {
  const [isDepositModalOpen, setIsDepositModalOpen] = useState(false);
  const [isWithdrawModalOpen, setIsWithdrawModalOpen] = useState(false);
  const [isRefreshing, setIsRefreshing] = useState(false);

  const handleRefresh = async () => {
    setIsRefreshing(true);
    try {
      await onRefresh();
      toast.success('Balances updated!');
    } catch (error) {
      toast.error('Failed to refresh balances');
    } finally {
      setIsRefreshing(false);
    }
  };

  const truncateAddress = (address: string) => {
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="bg-primary-600 p-2 rounded-lg">
                <Wallet className="w-6 h-6 text-white" />
              </div>
              <h1 className="text-2xl font-bold text-gray-900">StarVault</h1>
            </div>

            <div className="flex items-center gap-3">
              {isConnected && (
                <button
                  onClick={handleRefresh}
                  disabled={isRefreshing}
                  className="p-2 text-gray-600 hover:text-primary-600 transition-colors disabled:opacity-50"
                  title="Refresh balances"
                >
                  <RefreshCw className={`w-5 h-5 ${isRefreshing ? 'animate-spin' : ''}`} />
                </button>
              )}

              {isConnected ? (
                <div className="flex items-center gap-3">
                  <div className="bg-primary-50 px-4 py-2 rounded-lg">
                    <p className="text-sm font-medium text-primary-900">
                      {truncateAddress(walletAddress!)}
                    </p>
                  </div>
                  <button
                    onClick={onDisconnect}
                    className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors font-medium"
                  >
                    Disconnect
                  </button>
                </div>
              ) : (
                <button
                  onClick={onConnect}
                  className="px-6 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-semibold flex items-center gap-2"
                >
                  <Wallet className="w-5 h-5" />
                  Connect Wallet
                </button>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        {!isConnected ? (
          <div className="text-center py-20">
            <div className="bg-white p-12 rounded-2xl shadow-lg max-w-md mx-auto">
              <Wallet className="w-16 h-16 text-primary-600 mx-auto mb-4" />
              <h2 className="text-2xl font-bold text-gray-900 mb-2">
                Welcome to StarVault
              </h2>
              <p className="text-gray-600 mb-6">
                Connect your Stellar wallet to start earning yield on your XLM
              </p>
              <button
                onClick={onConnect}
                className="px-8 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors font-semibold"
              >
                Connect Wallet
              </button>
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {/* Vault Card */}
            <div className="relative">
              <VaultCard
                totalDeposits={totalDeposits}
                apy={apy}
                userBalance={vaultBalance}
                isLoading={isLoading}
              />
            </div>

            {/* Actions Panel */}
            <div className="space-y-6">
              {/* Wallet Balance Card */}
              <div className="bg-white rounded-2xl shadow-lg p-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">
                  Wallet Balance
                </h3>
                <p className="text-3xl font-bold text-gray-900">
                  {isLoading ? (
                    <span className="animate-pulse">...</span>
                  ) : (
                    <>
                      {walletBalance} <span className="text-xl text-gray-500">XLM</span>
                    </>
                  )}
                </p>
              </div>

              {/* Action Buttons */}
              <div className="grid grid-cols-2 gap-4">
                <button
                  onClick={() => setIsDepositModalOpen(true)}
                  disabled={isLoading}
                  className="bg-primary-600 text-white p-6 rounded-xl hover:bg-primary-700 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100"
                >
                  <ArrowDownCircle className="w-8 h-8 mx-auto mb-2" />
                  <span className="font-semibold">Deposit</span>
                </button>

                <button
                  onClick={() => setIsWithdrawModalOpen(true)}
                  disabled={isLoading || parseFloat(vaultBalance) === 0}
                  className="bg-orange-600 text-white p-6 rounded-xl hover:bg-orange-700 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100"
                >
                  <ArrowUpCircle className="w-8 h-8 mx-auto mb-2" />
                  <span className="font-semibold">Withdraw</span>
                </button>
              </div>

              {/* Info Cards */}
              <div className="bg-gradient-to-r from-primary-50 to-blue-50 rounded-xl p-6">
                <h4 className="font-semibold text-gray-900 mb-3">How it works</h4>
                <ul className="space-y-2 text-sm text-gray-700">
                  <li className="flex items-start gap-2">
                    <span className="text-primary-600 font-bold">1.</span>
                    <span>Deposit your XLM into the StarVault smart contract</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <span className="text-primary-600 font-bold">2.</span>
                    <span>Your tokens automatically earn yield based on the current APY</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <span className="text-primary-600 font-bold">3.</span>
                    <span>Withdraw anytime with no lock-up period</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        )}
      </main>

      {/* Modals */}
      <DepositModal
        isOpen={isDepositModalOpen}
        onClose={() => setIsDepositModalOpen(false)}
        onDeposit={onDeposit}
        maxBalance={walletBalance}
        isLoading={isLoading}
      />

      <WithdrawModal
        isOpen={isWithdrawModalOpen}
        onClose={() => setIsWithdrawModalOpen(false)}
        onWithdraw={onWithdraw}
        maxBalance={vaultBalance}
        isLoading={isLoading}
      />
    </div>
  );
};

export default VaultDashboard;
