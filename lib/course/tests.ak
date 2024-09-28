use cardano/address.{Address, Script, VerificationKey}
use cardano/assets.{Value}
use cardano/transaction.{Datum, Input, Output, OutputReference}

pub fn input(oref: OutputReference, output: Output) -> Input {
  let input = Input { output_reference: oref, output }

  input
}

pub fn oref(id: ByteArray, index: Int) -> OutputReference {
  let oref = OutputReference { transaction_id: id, output_index: index }
  oref
}

pub fn output(addr: Address, value: Value, datum: Datum) -> Output {
  let output = Output { address: addr, value, datum, reference_script: None }

  output
}

pub fn scriptAddress(hash: ByteArray) -> Address {
  let address =
    Address { payment_credential: Script(hash), stake_credential: None }

  address
}

pub fn walletAddress(hash: ByteArray) -> Address {
  let address =
    Address {
      payment_credential: VerificationKey(hash),
      stake_credential: None,
    }

  address
}

pub fn makeAsset(
  policyId: ByteArray,
  assetName: ByteArray,
  quantity: Int,
) -> Value {
  let asset = assets.from_asset(policyId, assetName, quantity)

  asset
}
