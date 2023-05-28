use cairo_test_2::ERC20::My_token;
use starknet::contract_address_const;
use starknet::ContractAddress;
use starknet::testing::set_caller_address;
use integer::u256;
use integer::u256_from_felt252;             // felt252 <- 31 char limit

const NAME: felt252 = 'Starknet Token';
const SYMBOL: felt252 = 'STAR';

// Helper function (initializes token with specific attributes)
fn setup() -> (ContractAddress, u256) {
    let initial_supply: u256 = u256_from_felt252(2000);
    let account: ContractAddress = contract_address_const::<1>();
    let decimals: u8 = 18_u8;

    set_caller_address(account);    // Set sender as caller of transfer functions

    My_token::constructor(NAME, SYMBOL, decimals, initial_supply, account);
    (account, initial_supply)
}


#[test]
#[available_gas(2000000)]
fn test_transfer() {
    let (sender, supply) = setup();         // sender is now address<1>, supply is now 2000
                                            // token created ('Starknet Token', 'STAR', 18_u8, 2000, token addy == sender)
    let recipient: ContractAddress = contract_address_const::<2>();     // recipient is now address<2>
    let amount: u256 = u256_from_felt252(100);
    My_token::transfer(recipient, amount);                              // sending 100 from address<1> to address<2>

    assert(My_token::balance_of(recipient) == amount, 'Balance should eq amount');
    assert(My_token::balance_of(sender) == supply - amount, 'Should eq supply - amount');
    assert(My_token::get_total_supply() == supply, 'Total supply should not change');
}


#[test]
#[available_gas(2000000)]
#[should_panic]
fn test_transfer_to_zero() {
    let (owner, supply) = setup();

    let recipient: ContractAddress = contract_address_const::<0>();
    let amount: u256 = u256_from_felt252(100);
    My_token::transfer(recipient, amount);
}


#[test]
#[available_gas(2000000)]
fn test_transfer_from() {
    let (sender, supply) = setup();
    let recipient: ContractAddress = contract_address_const::<4>();
    let amount: u256 = u256_from_felt252(150);

    My_token::approve(sender, amount);
    My_token::approve(recipient, amount);
    My_token::transfer_from(sender, recipient, amount);

    assert(My_token::allowance(sender, recipient) == amount, 'Approve does not match.'); 
    assert(My_token::balance_of(recipient) == amount, 'Balance does not match.');
    assert(My_token::balance_of(sender) == supply - amount, 'Should eq supply - amount');
    assert(My_token::get_total_supply() == supply, 'Total supply should not change');    
}