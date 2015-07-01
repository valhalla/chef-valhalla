# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: _restart
#

include_recipe 'runit::default'

# httpd
runit_service 'prime-httpd' do
  action  :restart
  only_if "test -h #{node[:runit][:service_dir]}/prime-httpd"
end

# cake layers
%w(loki thor odin tyr).each do |layer|
  # proxy
  runit_service "proxyd-#{layer}" do
    action  :restart
    only_if "test -h #{node[:runit][:service_dir]}/proxyd-#{layer}"
  end

  # workers
  (0..(node[:valhalla][:workers][:count] - 1)).step(1).each do |num|
    runit_service "workerd-#{layer}-#{num}" do
      action  :restart
      only_if "test -h #{node[:runit][:service_dir]}/workerd-#{layer}-#{num}"
    end
  end
end

# make sure everything is working by issuing a request
execute 'test service' do
  action  :run
  user    node[:valhalla][:user][:name]
  command "#{node[:valhalla][:conf_dir]}/health_check.sh"
  only_if "test -h #{node[:runit][:service_dir]}/prime-httpd"
end
