use b/oracle
use cardano/assets
use cardano/transaction.{InlineDatum, NoDatum, Transaction, placeholder}
use course/tests as t
use course/types.{OBurn, OClose, OMint, OUpdate, OracleDatum}

// Oracle Validator Tests //

// Oracle Update
test oracleUpdate() {
  let exchange = 1000
  let timestamp = 1111111111112
  let currency = "USD"

  let oneshot = t.oref(#"face", 1)
  let oraclePolicy = #"dead"
  let oracleToken = ""
  let oracleValue = t.makeAsset(oraclePolicy, oracleToken, 1)

  let oref = t.oref(#"cafe", 1)

  let inDatum =
    OracleDatum { exchange: 500, timestamp: 1111111111111, currency }
  let outDatum = OracleDatum { exchange, timestamp, currency }
  let oracleAction = OUpdate { exchange, timestamp }

  let oracleIn =
    t.input(
      oref,
      t.output(
        t.scriptAddress(oraclePolicy),
        // matches policyId
        oracleValue,
        InlineDatum(inDatum),
      ),
    )

  let oracleOut =
    t.output(t.scriptAddress(oraclePolicy), oracleValue, InlineDatum(outDatum))

  let tx =
    Transaction { ..placeholder, inputs: [oracleIn], outputs: [oracleOut] }

  oracle.oracle.spend(oneshot, Some(inDatum), oracleAction, oref, tx)
}

// Oracle Close 
test oracleClose() {
  let exchange = 1000
  let timestamp = 1111111111111
  // how can we limit the length of an integer?
  // we need to ensure that the integer is always 13digits long.
  let currency = "USD"

  let oneshot = t.oref(#"face", 1)
  let oref = t.oref(#"deaf", 4)
  let oraclePolicy = #"dead"
  let oracleToken = ""
  let oracleValue = t.makeAsset(oraclePolicy, oracleToken, 1)
  let oracleBurnValue = t.makeAsset(oraclePolicy, oracleToken, -1)

  let oracleAction = OClose
  let oracleDatum = OracleDatum { exchange, timestamp, currency }

  let oracleIn =
    t.input(
      oref,
      t.output(
        t.scriptAddress(oraclePolicy),
        oracleValue,
        InlineDatum(oracleDatum),
      ),
    )

  let tx =
    Transaction { ..placeholder, inputs: [oracleIn], mint: oracleBurnValue }

  oracle.oracle.spend(oneshot, Some(oracleDatum), oracleAction, oref, tx)?
}

// Oracle Mint 
test oracleMint() {
  let exchange = 1000
  let timestamp = 1111111111111
  let currency = "USD"

  let oref = t.oref(#"face", 1)
  let oraclePolicy = #"dead"
  let oracleToken = ""
  let oracleValue = t.makeAsset(oraclePolicy, oracleToken, 1)

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

  oracle.oracle.mint(oref, oracleMintAction, oraclePolicy, tx)?
}

// Oracle Burn 
test oracleBurn() {
  let exchange = 1000
  let timestamp = 1111111111111
  let currency = "USD"

  let oref = t.oref(#"face", 1)
  let oraclePolicy = #"dead"
  let oracleToken = ""
  let oracleValue = t.makeAsset(oraclePolicy, oracleToken, 1)
  let oracleBurnValue = t.makeAsset(oraclePolicy, oracleToken, -1)

  let oracleMintAction = OBurn
  let oracleDatum = OracleDatum { exchange, timestamp, currency }

  let oracleIn =
    t.input(
      t.oref(#"deaf", 4),
      t.output(
        t.scriptAddress(oraclePolicy),
        oracleValue,
        InlineDatum(oracleDatum),
      ),
    )

  let tx =
    Transaction { ..placeholder, inputs: [oracleIn], mint: oracleBurnValue }

  oracle.oracle.mint(oref, oracleMintAction, oraclePolicy, tx)?
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

  oracle.oracle.mint(oref, oracleMintAction, oraclePolicy, tx)?
}
