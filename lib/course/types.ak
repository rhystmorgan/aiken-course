pub type MarketDatum {
  price: Int, 
  seller: ByteArray,
}

pub type MarketAction { 
  MBuy
  MEdit { price: Int }
  MDelist
}