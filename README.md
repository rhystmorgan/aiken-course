# Aiken Course

This is the Aiken Course! Empowered by the Cardano Foundation

In this course we are going to be taking budding smart contract developers on a journey from basic validators through to complex dapps with multi validators, optimisations and TESTS!

Its going to be a smooth & casual ride that will introduce concepts as we develop our validators, to carefully guide people through the complexities of the eUTxO model and how to think about systems used for constructing production ready Dapps.

## Course Material:

Introduction - Setup & Using Aiken

Firstly we walk through setting up Aiken and the basecs or writing validators
  -> Installation
  -> Project Organistion
  -> Writing Validators

Module 1 - Basic Marketplace

This is going to be a single validator to introduce Aiken and basic data types in validators
  -> I/O
  -> Datums
  -> Redeemers
  -> Signatories / Wallet && Script Credentials

Module 2 - Testing Validators

We look at writing tests for our validators to benchmark and understand how the transactions will be built
  -> Unit Tests
  -> Passing Tests for Redeemer Cases
  -> Test tools helper functions
  -> Failing Tests

Module 3 - Oracle

This will teach people the most common design pattern of a mintingPolicy & spendingValidator pair
  -> Trusted data sources
  -> Spending to yourself
  -> Oneshot minting policy pattern

Module 4 - Common Exploits

This Module will walk through some common exploits we need to protect against
  -> Bypassing checks
  -> Double Satisfaction
  -> Token Swap
  -> Stake Injection
  -> Junk Tokens
  -> Datum Validity

Module 3 - USD Marketplace

Using our oracle in our marketplace to charge in 'USD'
  -> Refernce Inputs
  -> checks against multiple I/Os

Module 4 - CIP68 Token Minting 

Write validators in the `validators` folder, and supporting functions in the `lib` folder using `.ak` as a file extension.

For example, as `validators/always_true.ak`

---

# Working With Aiken

```aiken
validator my_first_validator {
  spend(_datum: Option<Data>, _redeemer: Data, _output_reference: Data, _context: Data) {
    True
  }
}
```

## Building

```sh
aiken build
```

## Testing

You can write tests in any module using the `test` keyword. For example:

```aiken
test foo() {
  1 + 1 == 2
}
```

To run all tests, simply do:

```sh
aiken check
```

To run only tests matching the string `foo`, do:

```sh
aiken check -m foo
```

## Documentation

If you're writing a library, you might want to generate an HTML documentation for it.

Use:

```sh
aiken docs
```

## Resources

Find more on the [Aiken's user manual](https://aiken-lang.org).
