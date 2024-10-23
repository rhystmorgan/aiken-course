//                     //
// Vulnerability Tests //
//                     //

// Denial Of Service //

// Dust Attack - See dust-attack.ak

// // Datum Attack
// pub type VulnDatum {
//   a: Int, // is 100 acceptable? is 99999999999999999999999999999999999+ acceptable?
//   b: ByteArray, // #"face" may be fine, but what about "098171234098743781201239458656754918761208478605978126346759048761098761238457679871623498576675348919028734656745923918763247599345871690873245905876203897450981239487569817634756998476531792837465"?
//   c: List<ByteArray> // [hash1, hash2, hash3, hash4] is probably alright, but what happens with 1000 hashes? 
// }
// // this will be fine
// pub const goodDatum {
//   a: 100,
//   b: #"cafe", 
//   c: [#"face", #"cafe", #"f00d"]
// }
// // this may be possible, and can result in an unspendable utxo
// pub const unspendableDatum {
//   a: 99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999,
//   b: "some crazy amount of digits that result in an unspendable utxo because the datum is too large to consume. This example might not be enough, but when you have lots of PloicyIDs or ScriptHashes being added to a datum, you will quickly result in an unspendable utxo, particularly if it is being used in the input and output, because it is automatically taking up double the space",
//   c: [hash1, hash2, hash3, hash4, hash5, hash6, hash7, hash8, hash9, hash10], 
// }

// Transaction Concurrency Attack

// Unauthorised Data Modification //

// Other Redeemer -> not checking tx state properly
// Stake Attack -> see stake-attack.ak

// Protocol Leaks //

// Token Swap
// Infinite Mint -> see infinite-mint.ak && policyMultiMint in oracle-test.ak
// Double Satisfaction -> see double-satisfaction.ak
