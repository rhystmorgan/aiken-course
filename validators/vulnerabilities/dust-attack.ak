use aiken/collection/list
use cardano/assets.{PolicyId}
use cardano/transaction.{
  Datum, InlineDatum, OutputReference, Redeemer, Transaction, placeholder,
}
use course/tests as t

// The goal of a dust attack, similar to a datum attack, is to leave the protocol with
// an unspendable UTxO

// HOMEWORK: Try and adjust this validator to prevent the attack test from passing

validator dust(p: PolicyId) {
  spend(_d: Option<Datum>, _r: Redeemer, oref: OutputReference, tx: Transaction) {
    expect Some(ownIn) =
      list.find(
        tx.inputs,
        fn(input) {
          input.output_reference == oref && list.has(
            assets.policies(input.output.value),
            p,
          )
        },
      )

    expect Some(ownOut) =
      list.find(
        tx.outputs,
        fn(output) { list.has(assets.policies(output.value), p) },
      )

    assets.lovelace_of(ownOut.value) >= 2000000
  }

  else(_) {
    fail
  }
}

test dustAttack() {
  let policy = #"0000"
  let oref = t.oref(#"cece", 1)
  let datum = #"aaaaaa"
  let redeemer = #"bbbbbb"

  let mainTokenValue = t.makeAsset(policy, #"1111", 1)
  let tokenMin = assets.merge(assets.from_lovelace(2000000), mainTokenValue)

  let dustTokens =
    t.makeAsset(#"0101", #"", 100)
      |> assets.merge(t.makeAsset(#"0202", #"0202", 234))
      |> assets.merge(t.makeAsset(#"0303", #"0303", 234))
      |> assets.merge(t.makeAsset(#"0404", #"0404", 234))
      |> assets.merge(t.makeAsset(#"0505", #"0505", 234))
      |> assets.merge(t.makeAsset(#"0606", #"0606", 234))
      |> assets.merge(t.makeAsset(#"0707", #"0707", 234))
      |> assets.merge(t.makeAsset(#"0808", #"0808", 234))
      |> assets.merge(t.makeAsset(#"0909", #"0909", 234))

  let input =
    t.input(
      oref,
      t.output(t.scriptAddress(#"face"), tokenMin, InlineDatum(datum)),
    )

  let output =
    t.output(
      t.scriptAddress(#"face"),
      assets.merge(tokenMin, dustTokens),
      InlineDatum(datum),
    )

  let tx = Transaction { ..placeholder, inputs: [input], outputs: [output] }

  dust.spend(policy, Some(InlineDatum(datum)), redeemer, oref, tx)
}
