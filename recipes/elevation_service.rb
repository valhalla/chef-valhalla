# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: elevation_service
#

include_recipe 'runit::default'

# httpd
runit_service 'prime-httpd' do
  action          :enable
  log             true
  default_logger  true
  sv_timeout      60
  retries         3
  options(skadi: first_layer)
  env(
    'LD_LIBRARY_PATH' => '/usr/lib:/usr/local/lib'
  )
end

# cake layers
%w(skadi).each do |layer|
  # proxy
  runit_service "proxyd-#{layer}" do
    action            :enable
    log               true
    default_logger    true
    run_template_name 'proxyd-global'
    sv_timeout        60
    retries           3
    options(layer: layer)
    env('LD_LIBRARY_PATH' => '/usr/lib:/usr/local/lib')
  end

  # workers
  (0..(node[:valhalla][:workers][:count] - 1)).step(1).each do |num|
    runit_service "workerd-#{layer}-#{num}" do
      action            :enable
      log               true
      default_logger    true
      run_template_name 'workerd-global'
      sv_timeout        60
      retries           3
      only_if           { node[:valhalla][:workers][:count] > 0 }
      options(layer: layer, num: num)
      env('LD_LIBRARY_PATH' => '/usr/lib:/usr/local/lib')
    end
  end
end
