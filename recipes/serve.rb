# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: serve
#

# httpd
ruint_service 'prime-httpd' do
  action          :enable
  log             true
  default_logger  true
  sv_timeout      60
  retries         3
  env(
    'LD_LIBRARY_PATH' => '/usr/lib:/usr/local/lib'
  )
end

# cake layers
%w(loki thor odin tyr).each do |layer|
  # proxy
  runit_service "proxyd-#{layer}" do
    action          :enable
    log             true
    default_logger  true
    sv_timeout      60
    retries         3
    env(
      'LD_LIBRARY_PATH' => '/usr/lib:/usr/local/lib'
    )
  end

  # workers
  %w(0 1 2 3 4 5 6 7).each do |n|
    runit_service "workerd-#{layer}-#{n}" do
      action          :enable
      log             true
      default_logger  true
      sv_timeout      60
      retries         3
      env(
        'LD_LIBRARY_PATH' => '/usr/lib:/usr/local/lib'
      )
    end
  end
end
