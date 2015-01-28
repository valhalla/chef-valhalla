# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: serve
#

# restart the service if all is well
runit_service 'tyr-service' do
  action          :enable
  log             true
  default_logger  true
  sv_timeout      60
  env(
    'LD_LIBRARY_PATH' => '/usr/lib:/usr/local/lib',
    'PYTHONPATH'      => '/usr/local/lib/python2.7/dist-packages'
  )
end
