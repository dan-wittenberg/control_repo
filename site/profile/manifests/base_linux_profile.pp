# @summary Base Linux OS profile
class profile::base_linux_profile {

  #the base profile should include component modules that will be on all nodes
  include ::base_linux

  # This will add custom facts to show if the host is vulnerable and tasks
  # to help with remediation
  include ::meltdown::linux

}
