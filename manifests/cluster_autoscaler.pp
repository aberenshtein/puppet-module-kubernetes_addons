class kubernetes_addons::cluster_autoscaler(
  String $image='gcr.io/google_containers/cluster-autoscaler',
  String $version='',
  String $limit_cpu='200m',
  String $limit_mem='500Mi',
  String $request_cpu='100m',
  String $request_mem='300Mi',
  Integer $min_instances=3,
  Integer $max_instances=6,
  $ca_mounts=$::kubernetes_addons::params::ca_mounts,
  $cloud_provider=$::kubernetes_addons::params::cloud_provider,
  $aws_region=$::kubernetes_addons::params::aws_region,
) inherits ::kubernetes_addons::params {
  require ::kubernetes

  $authorization_mode = $::kubernetes::_authorization_mode
  if member($authorization_mode, 'RBAC'){
    $rbac_enabled = true
  } else {
    $rbac_enabled = false
  }

  if defined('$kubernetes::cluster_name') {
    $asg_name="kubernetes-${::kubernetes::cluster_name}-worker"
  } else {
    $asg_name=undef
  }

  if $version == '' {
    if versioncmp($::kubernetes::version, '1.7.0') >= 0 {
      $_version = '0.6.0'
    } elsif versioncmp($::kubernetes::version, '1.6.0') >= 0 {
      $_version = '0.5.4'
    } elsif versioncmp($::kubernetes::version, '1.5.0') >= 0 {
      $_version = '0.4.0'
    } else {
      $_version = '0.3.0'
    }
  } else {
    $_version = $version
  }

  if versioncmp($::kubernetes::version, '1.6.0') >= 0 {
    $version_before_1_6 = false
  } else {
    $version_before_1_6 = true
  }


  kubernetes::apply{'cluster-autoscaler':
    manifests => [
      template('kubernetes_addons/cluster-autoscaler-deployment.yaml.erb'),
    ],
  }
}
