use aiken/collection/list
use aiken/primitive/string
use cardano/address.{VerificationKey}
use cardano/assets
use cardano/transaction.{InlineDatum, OutputReference, Transaction}
use course/types.{MBuy, MDelist, MEdit, MarketAction, MarketDatum}

// Market Validator Module 1 //

validator market {
  spend(
    datum: Option<MarketDatum>,
    r: MarketAction,
    oref: OutputReference,
    tx: Transaction,
  ) {
    // Sell assets for fixed price ADA
    // Seller can remove assets ( Delist )
    // Seller can update listing ( Edit )
    // Anyone can buy if they pay the seller ( Buy )
    trace @"Spending UTxO ..."

    expect Some(d) = datum

    when r is {
      MBuy -> {
        // seller gets paid the listed amount
        expect Some(payment) =
          // output to seller address
          list.find(
            tx.outputs,
            fn(output) {
              output.address.payment_credential == VerificationKey(d.seller)
            },
          )

        trace string.concat(
          @"Buying asset for: ",
          string.from_int(assets.lovelace_of(payment.value)),
        )

        // payment value is correct
        assets.lovelace_of(payment.value) == d.price
      }
      MEdit { price } -> {
        // change MarketDatum.price -> return to marketplace
        expect Some(ownInput) =
          list.find(tx.inputs, fn(input) { input.output_reference == oref })

        let ownHash = ownInput.output.address.payment_credential

        // script Output has same Value as input
        expect Some(ownOutput) =
          list.find(
            tx.outputs,
            fn(output) {
              output.address.payment_credential == ownHash && output.value == ownInput.output.value
            },
          )

        // check output Datum is MarketDatum
        expect InlineDatum(datum) = ownOutput.datum
        expect newDatum: MarketDatum = datum

        trace string.concat(
          @"Editing price to: ",
          string.from_int(newDatum.price),
        )

        // check newDatum Values && signature
        and {
          newDatum.seller == d.seller,
          newDatum.price == price,
          list.has(tx.extra_signatories, d.seller),
        }
      }
      MDelist -> {
        trace @"Delisting asset"
        // Only if signed by Seller
        list.has(tx.extra_signatories, d.seller)?
      }
    }
  }

  else(_) {
    fail
  }
}
