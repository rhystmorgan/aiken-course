use a/market
use cardano/address.{Address, Script, VerificationKey}
use cardano/assets.{AssetName, PolicyId}
use cardano/transaction.{
  InlineDatum, Input, NoDatum, Output, OutputReference, Transaction, placeholder,
}
use course/types.{MBuy, MDelist, MEdit, MarketDatum}

//                          //
// Double Satisfaction Test //
//                          //

// enables a single utxo to satisfy multiple validator checks, enabling someone to 
// withdraw more than is intended by the validator

// HOMEWORK: prevent this test from passing whilst still passing the main tests in
// market-test.ak

test marketplaceBuy() {
  let buyer = #"face"
  let seller = #"cafe"

  let oref = OutputReference { transaction_id: #"cece", output_index: 1 }
  let vref = OutputReference { transaction_id: #"cece", output_index: 2 }

  let tokenPolicy: PolicyId = #"dead"
  let tokenName: AssetName = #"beef"

  let vulnToken = assets.from_asset(#"deaf", #"feed", 1)

  let marketDatum = MarketDatum { price: 200, seller }
  let marketAction = MBuy

  let assetValue = assets.from_asset(tokenPolicy, tokenName, 1)

  let marketValue = assets.merge(assets.from_lovelace(2), assetValue)

  let buyerIn =
    Input {
      output_reference: OutputReference {
        transaction_id: buyer,
        output_index: 4,
      },
      output: Output {
        address: Address {
          payment_credential: VerificationKey(buyer),
          stake_credential: None,
        },
        value: assets.from_lovelace(200),
        datum: NoDatum,
        reference_script: None,
      },
    }

  let marketIn =
    // Legit spending
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

  let vulnIn =
    // naughty spending
    Input {
      output_reference: vref,
      output: Output {
        address: Address {
          payment_credential: Script(#"deaf"),
          stake_credential: None,
        },
        value: vulnToken,
        datum: InlineDatum(marketDatum),
        reference_script: None,
      },
    }

  let buyerOut =
    Output {
      address: Address {
        payment_credential: VerificationKey(buyer),
        stake_credential: None,
      },
      value: marketValue,
      datum: NoDatum,
      reference_script: None,
    }

  let vulnOut =
    // exploited withdrawl of token/utxo
    Output {
      address: Address {
        payment_credential: VerificationKey(buyer),
        stake_credential: None,
      },
      value: vulnToken,
      datum: NoDatum,
      reference_script: None,
    }

  let sellerOut =
    Output {
      address: Address {
        payment_credential: VerificationKey(seller),
        stake_credential: None,
      },
      value: assets.from_lovelace(200),
      datum: NoDatum,
      reference_script: None,
    }

  let tx =
    Transaction {
      ..placeholder,
      inputs: [buyerIn, marketIn, vulnIn],
      outputs: [buyerOut, sellerOut, vulnOut],
    }

  and {
    market.market.spend(Some(marketDatum), marketAction, oref, tx)?,
    market.market.spend(Some(marketDatum), marketAction, vref, tx)?,
  }
}
