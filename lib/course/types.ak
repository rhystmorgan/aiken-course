pub type MarketDatum {
  price: Int,
  seller: ByteArray,
}

pub type MarketAction {
  MBuy
  MEdit { price: Int }
  MDelist
}

pub type OracleDatum {
  exchange: Int,
  timestamp: Int,
  currency: ByteArray,
}

pub type OracleAction {
  OUpdate { exchange: Int, timestamp: Int }
  OClose
}

pub type OracleMintAction {
  OMint { exchange: Int, timestamp: Int, currency: ByteArray }
  OBurn
}
