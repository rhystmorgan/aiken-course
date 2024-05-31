# Aiken Course

This is the Aiken Course! Brought to you by the Cardano Foundation

In this course we are going to be taking budding smart contract developers on a journey from basic validators through to complex dapps with multi validators, optimisations and TESTS!

Its going to be a smooth & casual ride that will introduce concepts as we develop our validators, to carefully guide people through the complexities of the eUTxO model and how to think about systems used for constructing production ready Dapps.

Scope of works:

Module 1 - Basic Marketplace

This is going to be a single validator to introduce Aiken and basic data types in validators
  -> I/O
  -> Datums
  -> Redeemers
  -> Signatories / Pkh && ScriptCredentials

Module 2 - Oracle

This will teach people the most common design pattern of a mintingPolicy & spendingValidator pair
  -> trusted data sources
  -> spending to yourself

Module 3 - USD Marketplace

Using our oracle in our marketplace to charge in 'USD'
  -> Refernce Inputs
  -> checks against multiple I/Os

Module 4 - Fractionalised Token 

---

## Working with aiken projects

Write validators in the `validators` folder, and supporting functions in the `lib` folder using `.ak` as a file extension.

For example, as `validators/always_true.ak`

```gleam
validator {
  fn spend(_datum: Data, _redeemer: Data, _context: Data) -> Bool {
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

```gleam
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
