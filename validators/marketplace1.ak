//                   //
// Datum && Redeemer //
//                   //

type MDatum {
  seller: VerificationKeyCredential,
  price: Int,
}

type MAction {
  Buy
  Edit { price: Int }
  Delist
}

//                       //
// Marketplace Validator //
//                       //

validator {
  fn market(d: MDatum, r: MAction, c: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = c
    expect Spend(oref) = purpose

    expect ownIn =
      list.find(
        transaction.inputs,
        fn(input) { input.output_reference == oref },
      )

    when r is {
      Buy -> {
        expect Some(payment) =
          list.find(
            transaction.outputs,
            fn(output) { output.address.payment_credential == d.seller },
          )

        let listing = value.without_lovelace(ownIn.output.value)

        payment.value == d.price
      }
      Edit { price } -> {
        let ownHash = ownIn.output.address.payment_credential

        expect Some(updatedListing) =
          list.find(
            transaction.outputs,
            fn(output) {
              output.address.payment_credential == ownHash
              output.value == ownIn.output.value
            },
          )

        expect InlineDatum(datum) = updatedListing.datum
        expect mDatum: MDatum = datum

        mDatum.seller == d.seller && mDatum.price == price && list.has(
          extra_signatories,
          d.seller,
        )
      }
      Delist -> list.has(extra_signatories, d.seller)
    }
  }
}
// Tests //

// todo
