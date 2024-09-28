use a/market
use cardano/assets
use cardano/transaction.{InlineDatum, NoDatum, Transaction, placeholder}
use course/tests as t
use course/types.{MBuy, MDelist, MEdit, MarketDatum}

// Market Tests //

test marketBuy() {
  let seller = #"face"
  let buyer = #"beef"

  let marketDatum = MarketDatum { price: 200, seller }
  let marketAction = MBuy

  let marketValue =
    assets.merge(assets.from_lovelace(2), t.makeAsset(#"dead", #"feed", 1))

  let oref = t.oref(#"cafe", 1)

  let marketIn =
    t.input(
      oref,
      t.output(t.scriptAddress(#"deaf"), marketValue, InlineDatum(marketDatum)),
    )

  let buyerIn =
    t.input(
      t.oref(#"cece", 2),
      t.output(t.walletAddress(buyer), assets.from_lovelace(200), NoDatum),
    )

  let buyerOut = t.output(t.walletAddress(buyer), marketValue, NoDatum)

  let sellerOut =
    t.output(t.walletAddress(seller), assets.from_lovelace(200), NoDatum)

  let tx =
    Transaction {
      ..placeholder,
      inputs: [buyerIn, marketIn],
      outputs: [buyerOut, sellerOut],
    }

  market.market.spend(Some(marketDatum), marketAction, oref, tx)
}

test marketEdit() {
  let seller = #"face"

  let marketDatum = MarketDatum { price: 200, seller }
  let marketAction = MEdit { price: 250 }

  let newDatum = MarketDatum { price: 250, seller }

  let marketValue =
    assets.merge(assets.from_lovelace(2), t.makeAsset(#"dead", #"feed", 1))

  let oref = t.oref(#"cafe", 1)

  let marketIn =
    t.input(
      oref,
      t.output(t.scriptAddress(#"deaf"), marketValue, InlineDatum(marketDatum)),
    )

  let marketOut =
    t.output(t.scriptAddress(#"deaf"), marketValue, InlineDatum(newDatum))

  let tx =
    Transaction {
      ..placeholder,
      inputs: [marketIn],
      outputs: [marketOut],
      extra_signatories: [seller],
    }

  market.market.spend(Some(marketDatum), marketAction, oref, tx)
}

test marketDelist() {
  let seller = #"face"

  let marketDatum = MarketDatum { price: 200, seller }
  let marketAction = MDelist

  let marketValue =
    assets.merge(assets.from_lovelace(2), t.makeAsset(#"dead", #"feed", 1))

  let oref = t.oref(#"cafe", 1)

  let marketIn =
    t.input(
      oref,
      t.output(t.scriptAddress(#"deaf"), marketValue, InlineDatum(marketDatum)),
    )

  let sellerOut = t.output(t.walletAddress(seller), marketValue, NoDatum)

  let tx =
    Transaction {
      ..placeholder,
      inputs: [marketIn],
      outputs: [sellerOut],
      extra_signatories: [seller],
    }

  market.market.spend(Some(marketDatum), marketAction, oref, tx)
}

test marketDelistFail() fail {
  let seller = #"face"
  let buyer = #"beef"

  let marketDatum = MarketDatum { price: 200, seller }
  let marketAction = MDelist

  let marketValue =
    assets.merge(assets.from_lovelace(2), t.makeAsset(#"dead", #"feed", 1))

  let oref = t.oref(#"cafe", 1)

  let marketIn =
    t.input(
      oref,
      t.output(t.scriptAddress(#"deaf"), marketValue, InlineDatum(marketDatum)),
    )

  let sellerOut = t.output(t.walletAddress(seller), marketValue, NoDatum)

  let tx =
    Transaction {
      ..placeholder,
      inputs: [marketIn],
      outputs: [sellerOut],
      extra_signatories: [buyer],
    }

  market.market.spend(Some(marketDatum), marketAction, oref, tx)?
}
