# @summary Base Windows OS profile
class profile::base_windows_profile {

  #the base profile should include component modules that will be on all nodes
  include ::base_windows

  # This will add custom facts to show if the host is vulnerable and tasks
  # to help with remediation
  include ::meltdown::windows

}
