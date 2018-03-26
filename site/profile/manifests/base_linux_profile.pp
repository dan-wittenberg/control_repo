# @summary Base Linux OS profile
class profile::base_linux_profile {

  #the base profile should include component modules that will be on all nodes
  include ::base_linux
  include ::meltdown::linux

}
