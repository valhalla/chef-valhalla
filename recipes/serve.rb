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

  subscribes :restart, "template[#{node[:valhalla][:conf_dir]}/#{node[:valhalla][:config]}]", :delayed
  node[:valhalla][:github][:repos].each do |repo|
    subscribes :restart, "git[#{node[:valhalla][:src_dir]}/#{repo}]", :delayed
  end
end
