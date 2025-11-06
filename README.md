# StarVault - Stellar DeFi Vault

A decentralized yield-generating vault built on the Stellar blockchain using Soroban smart contracts. Users can deposit XLM and earn yield automatically through the vault's APY mechanism.

## 🌟 Features

- **Secure Smart Contracts**: Built with Rust and Soroban for maximum security
- **Yield Generation**: Automatic APY-based yield accrual
- **Instant Deposits/Withdrawals**: No lock-up period required
- **Modern UI**: Beautiful React interface with TailwindCSS
- **Wallet Integration**: Seamless connection with Freighter and other Stellar wallets
- **Real-time Updates**: Live balance and vault statistics

## 📁 Project Structure

```
.
├── contracts/
│   └── vault/
│       ├── src/
│       │   └── lib.rs           # Main vault smart contract
│       └── Cargo.toml            # Rust dependencies
│
└── frontend/
    ├── src/
    │   ├── components/
    │   │   ├── VaultDashboard.tsx    # Main dashboard component
    │   │   ├── VaultCard.tsx         # Vault stats card
    │   │   ├── DepositModal.tsx      # Deposit interface
    │   │   └── WithdrawModal.tsx     # Withdrawal interface
    │   ├── utils/
    │   │   └── stellar.ts            # Stellar SDK integration
    │   ├── App.tsx                   # Main app component
    │   ├── main.tsx                  # Entry point
    │   └── index.css                 # Global styles
    ├── package.json
    ├── vite.config.ts
    ├── tailwind.config.js
    └── tsconfig.json
```

## 🚀 Quick Start

### Prerequisites

- Node.js (v18+)
- Rust and Cargo
- Stellar CLI (`stellar-cli`)
- Freighter Wallet browser extension

### 1. Install Dependencies

#### Frontend
```bash
cd frontend
npm install
```

#### Smart Contract
```bash
cd contracts/vault
cargo build --target wasm32-unknown-unknown --release
```

### 2. Deploy Smart Contract

First, make sure you have the Stellar CLI installed:
```bash
cargo install --locked stellar-cli --features opt
```

Build the contract:
```bash
cd contracts/vault
stellar contract build
```

Deploy to testnet:
```bash
# Set your identity (use the provided test credentials)
stellar keys generate deployer --network testnet

# Deploy the vault contract
stellar contract deploy \
  --wasm target/wasm32-unknown-unknown/release/vault_contract.wasm \
  --source deployer \
  --network testnet

# Save the contract ID that's returned
```

Initialize the vault:
```bash
stellar contract invoke \
  --id <YOUR_VAULT_CONTRACT_ID> \
  --source deployer \
  --network testnet \
  -- \
  initialize \
  --admin <YOUR_ADMIN_ADDRESS> \
  --token CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC \
  --apy 500
```

### 3. Configure Frontend

Create a `.env` file in the `frontend` directory:
```bash
cd frontend
cp .env.example .env
```

Edit `.env` and add your deployed contract ID:
```
VITE_VAULT_CONTRACT_ID=<YOUR_VAULT_CONTRACT_ID>
VITE_TOKEN_CONTRACT_ID=CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC
```

### 4. Run the Frontend

```bash
cd frontend
npm run dev
```

The app will be available at `http://localhost:3000`

## 💡 Smart Contract Functions

### User Functions

- **`deposit(user: Address, amount: i128)`**
  - Deposits XLM into the vault
  - Starts earning yield immediately
  - Emits `deposit` event

- **`withdraw(user: Address, amount: i128)`**
  - Withdraws XLM from the vault
  - No lock-up period
  - Emits `withdraw` event

- **`get_balance(user: Address) -> i128`**
  - Returns user's deposited balance
  - Balance includes accrued yield

- **`get_vault_info() -> VaultInfo`**
  - Returns total deposits and current APY

### Admin Functions

- **`initialize(admin: Address, token: Address, apy: i128)`**
  - Initializes the vault contract
  - Sets admin, token, and initial APY
  - Can only be called once

- **`accrue_yield()`**
  - Accrues yield to all depositors
  - Called periodically by admin/keeper
  - Calculates yield based on APY and time elapsed

- **`update_apy(new_apy: i128)`**
  - Updates the vault's APY
  - Admin only
  - APY in basis points (500 = 5%)

## 🎨 Frontend Components

### VaultDashboard
Main component that orchestrates the entire UI. Handles wallet connection, balance updates, and modal states.

### VaultCard
Displays vault statistics including:
- User's deposited balance
- Current APY
- Total value locked (TVL)

### DepositModal
Modal interface for depositing XLM:
- Input validation
- Max balance button
- Real-time balance display
- Error handling

### WithdrawModal
Modal interface for withdrawing XLM:
- Input validation
- Max withdrawal amount
- Confirmation flow

## 🔧 Development

### Build Contract
```bash
cd contracts/vault
stellar contract build
```

### Run Tests
```bash
cd contracts/vault
cargo test
```

### Frontend Development
```bash
cd frontend
npm run dev        # Start dev server
npm run build      # Build for production
npm run preview    # Preview production build
```

## 📝 Environment Variables

The project uses the following test credentials (already configured):

- **STELLAR_SECRET_PHRASE**: Test account secret phrase
- **STELLAR_PUBLIC_KEY**: Test account public key (has 10,000 XLM on testnet)

These are automatically available in the environment and can be used for deployment and testing.

## 🔒 Security Considerations

1. **Smart Contract Auditing**: Before mainnet deployment, have the contract professionally audited
2. **Access Control**: Admin functions are protected with `require_auth()`
3. **Input Validation**: All user inputs are validated in both contract and frontend
4. **Rate Limiting**: Consider implementing rate limits for production
5. **Yield Mechanism**: Current yield is simulated - integrate with actual DeFi protocols for production

## 🚢 Deployment Checklist

- [ ] Deploy and verify smart contract on testnet
- [ ] Initialize vault with proper parameters
- [ ] Test all contract functions
- [ ] Configure frontend environment variables
- [ ] Test wallet connection (Freighter)
- [ ] Test deposit flow
- [ ] Test withdrawal flow
- [ ] Verify balance updates
- [ ] Check error handling
- [ ] Deploy frontend to hosting service (Vercel, Netlify, etc.)

## 📚 Resources

- [Stellar Documentation](https://developers.stellar.org/)
- [Soroban Documentation](https://soroban.stellar.org/docs)
- [Stellar Wallets Kit](https://github.com/Creit-Tech/Stellar-Wallets-Kit)
- [Stellar SDK](https://stellar.github.io/js-stellar-sdk/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - see LICENSE file for details

## 🎯 Hackathon Submission

This project was built for the Stellar blockchain hackathon. It demonstrates:
- Soroban smart contract development
- Stellar wallet integration
- Modern frontend development with React
- DeFi vault mechanics
- Real-world use case for yield generation

## 🐛 Known Issues & Future Improvements

- [ ] Implement actual yield generation mechanism (integrate with lending protocols)
- [ ] Add multi-asset support
- [ ] Implement automatic yield compounding
- [ ] Add transaction history
- [ ] Implement governance for APY adjustments
- [ ] Add analytics dashboard
- [ ] Mobile responsive optimizations
- [ ] Add deposit/withdrawal limits

## 💬 Support

For issues, questions, or contributions, please open an issue on GitHub.

---

Built with ❤️ for the Stellar ecosystem
