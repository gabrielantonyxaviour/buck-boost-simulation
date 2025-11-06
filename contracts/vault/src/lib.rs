#![no_std]
use soroban_sdk::{
    contract, contractimpl, contracttype, token, Address, Env, Symbol, Vec, symbol_short,
};

#[derive(Clone)]
#[contracttype]
pub enum DataKey {
    Balance(Address),
    TotalDeposits,
    Admin,
    Token,
    LastYieldAccrual,
    APY,
}

#[contracttype]
#[derive(Clone)]
pub struct VaultInfo {
    pub total_deposits: i128,
    pub apy: i128, // APY in basis points (e.g., 500 = 5%)
}

#[contract]
pub struct VaultContract;

const DAY_IN_LEDGERS: u32 = 17280; // Assuming ~5 second ledgers

#[contractimpl]
impl VaultContract {
    /// Initialize the vault with admin and token address
    pub fn initialize(env: Env, admin: Address, token: Address, apy: i128) {
        if env.storage().instance().has(&DataKey::Admin) {
            panic!("Already initialized");
        }

        admin.require_auth();

        env.storage().instance().set(&DataKey::Admin, &admin);
        env.storage().instance().set(&DataKey::Token, &token);
        env.storage().instance().set(&DataKey::TotalDeposits, &0i128);
        env.storage().instance().set(&DataKey::APY, &apy);
        env.storage().instance().set(&DataKey::LastYieldAccrual, &env.ledger().sequence());

        env.events().publish(
            (symbol_short!("init"),),
            (admin.clone(), token.clone(), apy),
        );
    }

    /// Deposit tokens into the vault
    pub fn deposit(env: Env, user: Address, amount: i128) -> i128 {
        user.require_auth();

        if amount <= 0 {
            panic!("Amount must be positive");
        }

        let token_address: Address = env.storage().instance().get(&DataKey::Token).unwrap();
        let token_client = token::Client::new(&env, &token_address);

        // Transfer tokens from user to contract
        token_client.transfer(&user, &env.current_contract_address(), &amount);

        // Update user balance
        let balance_key = DataKey::Balance(user.clone());
        let current_balance: i128 = env.storage().instance().get(&balance_key).unwrap_or(0);
        let new_balance = current_balance + amount;
        env.storage().instance().set(&balance_key, &new_balance);

        // Update total deposits
        let total: i128 = env.storage().instance().get(&DataKey::TotalDeposits).unwrap();
        env.storage().instance().set(&DataKey::TotalDeposits, &(total + amount));

        env.events().publish(
            (symbol_short!("deposit"),),
            (user.clone(), amount, new_balance),
        );

        new_balance
    }

    /// Withdraw tokens from the vault
    pub fn withdraw(env: Env, user: Address, amount: i128) -> i128 {
        user.require_auth();

        if amount <= 0 {
            panic!("Amount must be positive");
        }

        let balance_key = DataKey::Balance(user.clone());
        let current_balance: i128 = env.storage().instance().get(&balance_key).unwrap_or(0);

        if current_balance < amount {
            panic!("Insufficient balance");
        }

        let token_address: Address = env.storage().instance().get(&DataKey::Token).unwrap();
        let token_client = token::Client::new(&env, &token_address);

        // Transfer tokens from contract to user
        token_client.transfer(&env.current_contract_address(), &user, &amount);

        // Update user balance
        let new_balance = current_balance - amount;
        env.storage().instance().set(&balance_key, &new_balance);

        // Update total deposits
        let total: i128 = env.storage().instance().get(&DataKey::TotalDeposits).unwrap();
        env.storage().instance().set(&DataKey::TotalDeposits, &(total - amount));

        env.events().publish(
            (symbol_short!("withdraw"),),
            (user.clone(), amount, new_balance),
        );

        new_balance
    }

    /// Get user's balance
    pub fn get_balance(env: Env, user: Address) -> i128 {
        let balance_key = DataKey::Balance(user);
        env.storage().instance().get(&balance_key).unwrap_or(0)
    }

    /// Get vault information
    pub fn get_vault_info(env: Env) -> VaultInfo {
        VaultInfo {
            total_deposits: env.storage().instance().get(&DataKey::TotalDeposits).unwrap_or(0),
            apy: env.storage().instance().get(&DataKey::APY).unwrap_or(0),
        }
    }

    /// Accrue yield to all depositors (simplified simulation)
    /// In production, this would be called periodically by an oracle or keeper
    pub fn accrue_yield(env: Env) {
        let admin: Address = env.storage().instance().get(&DataKey::Admin).unwrap();
        admin.require_auth();

        let current_ledger = env.ledger().sequence();
        let last_accrual: u32 = env.storage().instance().get(&DataKey::LastYieldAccrual).unwrap();
        let ledgers_elapsed = current_ledger - last_accrual;

        if ledgers_elapsed < DAY_IN_LEDGERS {
            // Not enough time has passed
            return;
        }

        let days_elapsed = ledgers_elapsed / DAY_IN_LEDGERS;
        let apy: i128 = env.storage().instance().get(&DataKey::APY).unwrap();
        let total_deposits: i128 = env.storage().instance().get(&DataKey::TotalDeposits).unwrap();

        // Calculate daily yield: APY / 365 / 10000 (basis points)
        // Simplified: yield = total * (apy / 365 / 10000) * days
        let yield_amount = (total_deposits * apy * days_elapsed as i128) / (365 * 10000);

        if yield_amount > 0 {
            let new_total = total_deposits + yield_amount;
            env.storage().instance().set(&DataKey::TotalDeposits, &new_total);
            env.storage().instance().set(&DataKey::LastYieldAccrual, &current_ledger);

            env.events().publish(
                (symbol_short!("yield"),),
                (yield_amount, new_total),
            );
        }
    }

    /// Get all user balances (for testing/admin purposes)
    pub fn get_all_balances(env: Env) -> Vec<(Address, i128)> {
        let admin: Address = env.storage().instance().get(&DataKey::Admin).unwrap();
        admin.require_auth();

        // In production, you'd implement proper indexing
        // This is a simplified version
        Vec::new(&env)
    }

    /// Update APY (admin only)
    pub fn update_apy(env: Env, new_apy: i128) {
        let admin: Address = env.storage().instance().get(&DataKey::Admin).unwrap();
        admin.require_auth();

        env.storage().instance().set(&DataKey::APY, &new_apy);

        env.events().publish(
            (symbol_short!("apy_upd"),),
            new_apy,
        );
    }

    /// Get token address
    pub fn get_token(env: Env) -> Address {
        env.storage().instance().get(&DataKey::Token).unwrap()
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use soroban_sdk::{testutils::Address as _, token, Address, Env};

    #[test]
    fn test_deposit_withdraw() {
        let env = Env::default();
        env.mock_all_auths();

        let admin = Address::generate(&env);
        let user = Address::generate(&env);
        let token_address = env.register_stellar_asset_contract(admin.clone());

        let contract_id = env.register_contract(None, VaultContract);
        let client = VaultContractClient::new(&env, &contract_id);

        // Initialize vault with 5% APY (500 basis points)
        client.initialize(&admin, &token_address, &500);

        // Mint tokens to user
        let token_client = token::Client::new(&env, &token_address);
        let token_admin = token::StellarAssetClient::new(&env, &token_address);
        token_admin.mint(&user, &1000);

        // Deposit
        client.deposit(&user, &100);
        assert_eq!(client.get_balance(&user), 100);

        let vault_info = client.get_vault_info();
        assert_eq!(vault_info.total_deposits, 100);

        // Withdraw
        client.withdraw(&user, &50);
        assert_eq!(client.get_balance(&user), 50);

        let vault_info = client.get_vault_info();
        assert_eq!(vault_info.total_deposits, 50);
    }
}
