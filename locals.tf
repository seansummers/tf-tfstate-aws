locals {
  this        = random_pet.tfstate.id
  external_id = random_string.external_id.result
}
