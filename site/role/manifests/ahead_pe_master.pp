# This class configures PE environments to AHEAD specs
# @summary Puppet Role - testing
class role::ahead_pe_master {

  if ( $facts['kernel'] == 'Linux' ){
    include ::profile::base_linux
    include ::profile::ahead_pe_master
  } else {
    notice ("ERROR: Only Linux is supported for ${name}. NO ACTION TAKEN")
    notify {"ERROR: Only Linux is supported for ${name}. NO ACTION TAKEN":}
  }
}
