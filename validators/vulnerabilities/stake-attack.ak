use a/market
use cardano/address.{Address, Inline, Script, VerificationKey}
use cardano/assets.{AssetName, PolicyId}
use cardano/transaction.{
  InlineDatum, Input, NoDatum, Output, OutputReference, Transaction, placeholder,
}
use course/types.{MBuy, MDelist, MEdit, MarketDatum}

//                   //
// Stake Attack Test //
//                   //

// HOMEWORK: Adjust the market validator to prevent a stake attack
// This test should fail, but the other tests should still pass (market-test.ak)

test marketEdit() {
  let seller = #"cafe"

  let tokenPolicy: PolicyId = #"dead"
  let tokenName: AssetName = #"beef"

  let marketDatum = MarketDatum { price: 200, seller }
  let marketDatum2 = MarketDatum { price: 300, seller }
  let marketAction = MEdit { price: 300 }

  let assetValue = assets.from_asset(tokenPolicy, tokenName, 1)

  let marketValue = assets.merge(assets.from_lovelace(2), assetValue)

  let sellerIn =
    Input {
      output_reference: OutputReference {
        transaction_id: seller,
        output_index: 4,
      },
      output: Output {
        address: Address {
          payment_credential: VerificationKey(seller),
          stake_credential: None,
        },
        value: assets.from_lovelace(200),
        datum: NoDatum,
        reference_script: None,
      },
    }

  let oref = OutputReference { transaction_id: #"cece", output_index: 1 }

  let marketIn =
    Input {
      output_reference: oref,
      output: Output {
        address: Address {
          payment_credential: Script(#"deaf"),
          stake_credential: None,
        },
        value: marketValue,
        datum: InlineDatum(marketDatum),
        reference_script: None,
      },
    }

  let marketOut =
    Output {
      address: Address {
        payment_credential: Script(#"deaf"),
        stake_credential: Some(Inline(VerificationKey(#"face"))),
      },
      value: marketValue,
      datum: InlineDatum(marketDatum2),
      reference_script: None,
    }

  let tx =
    Transaction {
      ..placeholder,
      inputs: [sellerIn, marketIn],
      outputs: [marketOut],
      extra_signatories: [seller],
    }

  market.market.spend(Some(marketDatum), marketAction, oref, tx)?
}
