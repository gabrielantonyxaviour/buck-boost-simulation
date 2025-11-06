import React, { useState } from 'react';
import { X, ArrowDownCircle, AlertCircle } from 'lucide-react';

interface DepositModalProps {
  isOpen: boolean;
  onClose: () => void;
  onDeposit: (amount: string) => Promise<void>;
  maxBalance: string;
  isLoading?: boolean;
}

const DepositModal: React.FC<DepositModalProps> = ({
  isOpen,
  onClose,
  onDeposit,
  maxBalance,
  isLoading = false,
}) => {
  const [amount, setAmount] = useState('');
  const [error, setError] = useState('');

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    const amountNum = parseFloat(amount);
    const maxNum = parseFloat(maxBalance);

    if (isNaN(amountNum) || amountNum <= 0) {
      setError('Please enter a valid amount');
      return;
    }

    if (amountNum > maxNum) {
      setError(`Insufficient balance. Max: ${maxBalance} XLM`);
      return;
    }

    try {
      await onDeposit(amount);
      setAmount('');
      onClose();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Deposit failed');
    }
  };

  const handleMaxClick = () => {
    setAmount(maxBalance);
    setError('');
  };

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6 relative">
        {/* Close button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 transition-colors"
          disabled={isLoading}
        >
          <X className="w-6 h-6" />
        </button>

        {/* Header */}
        <div className="flex items-center gap-3 mb-6">
          <div className="bg-primary-100 p-3 rounded-xl">
            <ArrowDownCircle className="w-6 h-6 text-primary-600" />
          </div>
          <h2 className="text-2xl font-bold text-gray-900">Deposit XLM</h2>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Amount
            </label>
            <div className="relative">
              <input
                type="number"
                step="0.000001"
                value={amount}
                onChange={(e) => {
                  setAmount(e.target.value);
                  setError('');
                }}
                placeholder="0.00"
                className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-transparent outline-none transition-all"
                disabled={isLoading}
              />
              <button
                type="button"
                onClick={handleMaxClick}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-primary-600 font-semibold text-sm hover:text-primary-700 transition-colors"
                disabled={isLoading}
              >
                MAX
              </button>
            </div>
            <p className="text-sm text-gray-500 mt-1">
              Available: {maxBalance} XLM
            </p>
          </div>

          {/* Error message */}
          {error && (
            <div className="flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-lg">
              <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0" />
              <p className="text-sm text-red-600">{error}</p>
            </div>
          )}

          {/* Submit button */}
          <button
            type="submit"
            disabled={isLoading || !amount}
            className="w-full bg-primary-600 text-white py-3 rounded-xl font-semibold hover:bg-primary-700 transition-colors disabled:bg-gray-300 disabled:cursor-not-allowed"
          >
            {isLoading ? (
              <span className="flex items-center justify-center gap-2">
                <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                Processing...
              </span>
            ) : (
              'Deposit'
            )}
          </button>
        </form>

        {/* Info */}
        <div className="mt-6 p-4 bg-primary-50 rounded-xl">
          <p className="text-sm text-primary-900">
            Your XLM will be deposited into the vault and start earning yield immediately.
          </p>
        </div>
      </div>
    </div>
  );
};

export default DepositModal;
