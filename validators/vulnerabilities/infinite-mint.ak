use aiken/collection/dict
use aiken/collection/list
use aiken/collection/pairs
use cardano/address.{Script}
use cardano/assets.{PolicyId}
use cardano/transaction.{
  InlineDatum, NoDatum, OutputReference, Transaction, placeholder,
}
use course/tests as t
use course/types.{
  OBurn, OClose, OMint, OUpdate, OracleAction, OracleDatum, OracleMintAction,
}

// Oracle Validator //

// HOMEWORK: can you exploit this?
// write failing tests for this oracle validator -> 1 for each case

// Trusted Data Feed
validator oracle(oneshot: OutputReference) {
  mint(r: OracleMintAction, p: PolicyId, tx: Transaction) {
    let Transaction { inputs, outputs, mint, .. } = tx

    let oracleMint =
      mint
        |> assets.tokens(p)
        |> dict.to_pairs()

    when r is {
      OMint { exchange, timestamp, currency } -> {
        expect Some(in) =
          list.find(inputs, fn(input) { input.output_reference == oneshot })

        // Output With Minted Token!
        expect Some(tokenOut) =
          list.find(
            outputs,
            fn(output) { list.has(assets.policies(output.value), p) },
          )

        // Needs to send to trusted validator
        expect Script(p) == tokenOut.address.payment_credential

        // Needs to have OracleDatum
        expect InlineDatum(d) = tokenOut.datum
        expect oracleDatum: OracleDatum = d

        and {
          // tokenName == "",
          // tokenQty == 1,
          oracleDatum.exchange == exchange,
          oracleDatum.timestamp == timestamp,
          oracleDatum.currency == currency,
        }
      }
      OBurn -> True
    }
  }

  spend(
    datum: Option<OracleDatum>,
    r: OracleAction,
    oref: OutputReference,
    tx: Transaction,
  ) {
    True
  }

  else(_) {
    fail
  }
}

// Infinite Mint Test //

// Oracle Mint 
test tokenMultiMint() {
  let exchange = 1000
  let timestamp = 1111111111111
  let currency = "USD"

  let oref = t.oref(#"face", 1)
  let oraclePolicy = #"dead"
  let oracleToken = ""
  let oracleValue = t.makeAsset(oraclePolicy, oracleToken, 100)

  let oracleMintAction = OMint { exchange, timestamp, currency }
  let oracleDatum = OracleDatum { exchange, timestamp, currency }

  let oneshot =
    t.input(
      oref,
      t.output(t.walletAddress(#"bace"), assets.from_lovelace(100), NoDatum),
    )

  let oracleOut =
    t.output(
      t.scriptAddress(oraclePolicy),
      oracleValue,
      InlineDatum(oracleDatum),
    )

  let tx =
    Transaction {
      ..placeholder,
      inputs: [oneshot],
      outputs: [oracleOut],
      mint: oracleValue,
    }

  oracle.mint(oref, oracleMintAction, oraclePolicy, tx)?
}

test policyMultiMint() {
  let exchange = 1000
  let timestamp = 1111111111111
  let currency = "USD"

  let oref = t.oref(#"face", 1)
  let oraclePolicy = #"dead"
  let oracleToken = ""
  let oracleValue = t.makeAsset(oraclePolicy, oracleToken, 100)

  let dustTokens =
    t.makeAsset(oraclePolicy, #"1111", 100)
      |> assets.merge(t.makeAsset(oraclePolicy, #"0202", 234))
      |> assets.merge(t.makeAsset(oraclePolicy, #"0303", 234))
      |> assets.merge(t.makeAsset(oraclePolicy, #"0404", 234))
      |> assets.merge(t.makeAsset(oraclePolicy, #"0505", 234))
      |> assets.merge(t.makeAsset(oraclePolicy, #"0606", 234))
      |> assets.merge(t.makeAsset(oraclePolicy, #"0707", 234))
      |> assets.merge(t.makeAsset(oraclePolicy, #"0808", 234))
      |> assets.merge(t.makeAsset(oraclePolicy, #"0909", 234))

  let oracleMintAction = OMint { exchange, timestamp, currency }
  let oracleDatum = OracleDatum { exchange, timestamp, currency }

  let oneshot =
    t.input(
      oref,
      t.output(t.walletAddress(#"bace"), assets.from_lovelace(100), NoDatum),
    )

  let oracleOut =
    t.output(
      t.scriptAddress(oraclePolicy),
      assets.merge(oracleValue, dustTokens),
      InlineDatum(oracleDatum),
    )

  let tx =
    Transaction {
      ..placeholder,
      inputs: [oneshot],
      outputs: [oracleOut],
      mint: assets.merge(oracleValue, dustTokens),
    }

  oracle.mint(oref, oracleMintAction, oraclePolicy, tx)?
}
