import React from 'react';
import { TrendingUp, Lock, Coins } from 'lucide-react';

interface VaultCardProps {
  totalDeposits: string;
  apy: string;
  userBalance: string;
  isLoading?: boolean;
}

const VaultCard: React.FC<VaultCardProps> = ({
  totalDeposits,
  apy,
  userBalance,
  isLoading = false,
}) => {
  return (
    <div className="bg-gradient-to-br from-primary-600 to-primary-800 rounded-2xl shadow-2xl p-8 text-white">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-3xl font-bold">StarVault</h2>
        <Lock className="w-8 h-8 opacity-80" />
      </div>

      <div className="space-y-6">
        {/* User Balance */}
        <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
          <div className="flex items-center gap-2 mb-2">
            <Coins className="w-5 h-5" />
            <span className="text-sm font-medium opacity-90">Your Balance</span>
          </div>
          <p className="text-4xl font-bold">
            {isLoading ? (
              <span className="animate-pulse">...</span>
            ) : (
              <>
                {userBalance} <span className="text-2xl opacity-80">XLM</span>
              </>
            )}
          </p>
        </div>

        {/* APY and Total Deposits */}
        <div className="grid grid-cols-2 gap-4">
          <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4">
            <div className="flex items-center gap-2 mb-2">
              <TrendingUp className="w-4 h-4" />
              <span className="text-xs font-medium opacity-90">APY</span>
            </div>
            <p className="text-2xl font-bold">
              {isLoading ? (
                <span className="animate-pulse">...</span>
              ) : (
                <>{apy}%</>
              )}
            </p>
          </div>

          <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4">
            <div className="flex items-center gap-2 mb-2">
              <Lock className="w-4 h-4" />
              <span className="text-xs font-medium opacity-90">Total Locked</span>
            </div>
            <p className="text-2xl font-bold">
              {isLoading ? (
                <span className="animate-pulse">...</span>
              ) : (
                <>{totalDeposits}</>
              )}
            </p>
          </div>
        </div>
      </div>

      {/* Animated gradient background */}
      <div className="absolute inset-0 bg-gradient-to-r from-primary-400/20 to-primary-600/20 rounded-2xl opacity-50 animate-gradient -z-10" />
    </div>
  );
};

export default VaultCard;
