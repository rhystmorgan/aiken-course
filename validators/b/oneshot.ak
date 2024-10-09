use aiken/collection/dict
use aiken/collection/list
use aiken/collection/pairs
use cardano/assets.{PolicyId}
use cardano/transaction.{OutputReference, Transaction}

// Oneshot Minting Policy //
pub type MintAction {
  OneMint
  OneBurn
}

// Can only be minted once
validator oneshot(oref: OutputReference) {
  mint(r: MintAction, p: PolicyId, tx: Transaction) {
    let Transaction { inputs, mint, .. } = tx

    expect [Pair(tokenName, tokenQty)] =
      mint
        |> assets.tokens(p)
        |> dict.to_pairs()

    when r is {
      OneMint -> {
        expect Some(in) =
          list.find(inputs, fn(input) { input.output_reference == oref })
        and {
          tokenName == "",
          tokenQty == 1,
        }
      }
      OneBurn -> tokenQty == -1
    }
  }

  else(_) {
    fail
  }
}
