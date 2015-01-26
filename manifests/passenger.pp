class puppet::passenger (
  $passenger_high_performance   = 'on',
  $passenger_max_pool_size      = '12',
  $passenger_max_requests       = '1000',
  $passenger_pool_idle_time     = '600',
  $passenger_stat_throttle_rate = '120',
  $passenger_use_global_queue   = 'on',
  $rack_autodetect              = 'on',
  $rails_autodetect             = 'on',
){
  class { 'apache':
    default_vhost => false,
  }
  class { 'apache::mod::passenger':
    passenger_high_performance   => $passenger_high_performance,
    passenger_max_pool_size      => $passenger_max_pool_size,
    passenger_max_requests       => $passenger_max_requests,
    passenger_pool_idle_time     => $passenger_pool_idle_time,
    passenger_stat_throttle_rate => $passenger_stat_throttle_rate,
    passenger_use_global_queue   => $passenger_use_global_queue,
    rack_autodetect              => $rack_autodetect,
    rails_autodetect             => $rails_autodetect,
  }
}
