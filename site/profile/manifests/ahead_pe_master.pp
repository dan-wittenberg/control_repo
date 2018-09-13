# @summary Configure some extra PE Master settings/utils
#
# @param control_repo URL of the control repo
# @param env_node_groups What environmental node groups should be configured
# @param node_groups What regular node groups should be configured
# @param pe_root_alias Where should root emails go to ensure a healthy environment
# @param enable_simple_whitelist Should we use simple whitelisting with hostnames instead of policy
# @param enable_policy_whitelist Should we use policy whitelisting
# @param autosign_whitelist Array of hostname pattners to add to the auto-whitelist
# @param autosign_preshared_key The preshared key used as a trusted fact of pp_preshared_key
# @param enable_report2slack Should we use the report2slack module
# @param enable_report2snow Should we use the report2snow module
# @param enable_report2s3bucket Should we use the report2s3bucket module
#
class profile::ahead_pe_master (
  Array $env_node_groups = ['production'],
  Array $node_groups = ['Puppet Dev Workstation'],
  String $control_repo = '',  #lint:ignore:empty_string_assignment
  String $pe_root_alias = 'root@localhost',
  Boolean $enable_simple_whitelist = false,
  Boolean $enable_policy_whitelist = true,
  Boolean $enable_report2slack = false,
  Boolean $enable_report2snow = false,
  Boolean $enable_report2s3bucket = false,
  String  $autosign_preshared_key = 'shared_secret_key',
  Array $autosign_whitelist = ["${facts['networking']['domain']}"],  #lint:ignore:only_variable_string
){

  if ( $facts['kernel'] == 'Linux' ){

    include ::puppet_metrics_collector

    class { '::pe_maintenance':
      #s3_bucket => 'path_to_bucket' # This will send backups to an S3 bucket
    }

    # Setup node groups, autosigning, and local system stuff
    class { '::pe_master_utils':
      control_repo            => $control_repo,
      env_node_groups         => $env_node_groups,
      node_groups             => $node_groups,
      pe_root_alias           => $pe_root_alias,
      enable_simple_whitelist => $enable_simple_whitelist,
      enable_policy_whitelist => $enable_policy_whitelist,
      autosign_preshared_key  => Sensitive($autosign_preshared_key),
      autosign_whitelist      => $autosign_whitelist,
    }

    # This will install the normal puppet gem AND puppetserver
    # This also installs and configures eyaml for encrypted secrets
    class { '::hiera':
      eyaml           => true,
      eyaml_version   => '2.1.0',
      eyaml_extension => '.yaml',
      create_keys     => true,
      keysdir         => '/etc/puppetlabs/code-staging/keys',
      provider        => 'puppetserver_gem',
    }

    # This module will send unintentional changes to a Slack channel
    if( $enable_report2slack ) {
      class { '::report2slack':
        webhook       => 'https://hooks.slack.com/services/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',
        channel       => '#puppet_notifications',
        puppetconsole => 'pe-2017-3-m01.aheadaviation.local',
      }
    }

    # This module will send unintentional changes to a SNOW ticket
    if( $enable_report2snow ) {
      class { '::report2snow':
        url => 'https://aheaddemo2.service-now.com/api/now/table/change_request?sysparm_input_display_value=true',
      }
    }

    # This module will dump puppet reports to an S3 bucket (AWS only)
    if( $enable_report2s3bucket ) {
      class { '::report2s3bucket':
        bucket => 'bucket_name',
      }
    }

  } else {
    notice ("ERROR: Only Linux is supported for ${name}. NO ACTION TAKEN")
    notify {"ERROR: Only Linux is supported for ${name}. NO ACTION TAKEN":}
  }

}
