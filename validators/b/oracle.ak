use aiken/collection/dict
use aiken/collection/list
use aiken/collection/pairs
use cardano/address.{Script}
use cardano/assets.{PolicyId}
use cardano/transaction.{InlineDatum, OutputReference, Transaction}
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

    expect [Pair(tokenName, tokenQty)] =
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
            fn(output) {
              assets.without_lovelace(output.value) == assets.from_asset(
                p,
                tokenName,
                tokenQty,
              )
            },
          )

        // Needs to send to trusted validator
        expect Script(p) == tokenOut.address.payment_credential

        // Needs to have OracleDatum
        expect InlineDatum(d) = tokenOut.datum
        expect oracleDatum: OracleDatum = d

        and {
          tokenName == "",
          tokenQty == 1,
          oracleDatum.exchange == exchange,
          oracleDatum.timestamp == timestamp,
          oracleDatum.currency == currency,
        }
      }
      OBurn -> tokenQty == -1
    }
  }

  spend(
    datum: Option<OracleDatum>,
    r: OracleAction,
    oref: OutputReference,
    tx: Transaction,
  ) {
    let Transaction { inputs, outputs, mint, .. } = tx
    // What we need:
    // own ScriptHash for Policy Id of Token
    // own Input for oracle token value
    // input has datum
    expect Some(d) = datum
    // find own input
    expect Some(ownInput) =
      list.find(inputs, fn(input) { input.output_reference == oref })

    // get script hash from credential
    let ownCredential = ownInput.output.address.payment_credential
    expect Script(scriptHash) = ownCredential

    when r is {
      // To Update : 
      OUpdate { exchange, timestamp } -> {
        // find own output with token && returned to validator
        expect Some(ownOut) =
          list.find(
            outputs,
            fn(output) {
              list.has(assets.policies(output.value), scriptHash) && output.address.payment_credential == ownCredential
            },
          )
        // check correct datum
        expect InlineDatum(dat) = ownOut.datum
        expect outDatum: OracleDatum = dat

        and {
          // new exchange && timestamp
          outDatum.exchange == exchange,
          outDatum.currency == d.currency,
          outDatum.timestamp == timestamp,
          timestamp > d.timestamp,
        }
      }

      // To Close:
      // token is burned
      OClose -> {
        // get input token
        let oracleValue =
          ownInput.output.value
            |> assets.tokens(scriptHash)
            |> dict.to_pairs()

        // filter mint field
        let burnValue =
          mint
            |> assets.tokens(scriptHash)
            |> dict.to_pairs()

        // value is burned
        and {
          pairs.keys(burnValue) == pairs.keys(oracleValue),
          pairs.values(burnValue) == [-1],
          pairs.values(oracleValue) == [1],
        }
      }
    }
  }

  else(_) {
    fail
  }
}
