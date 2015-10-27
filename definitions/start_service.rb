# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Definition:: start_service
#

define :start_service do
  # httpd
  runit_service 'prime-httpd' do
    action  :start
    only_if "test -h #{node[:runit][:service_dir]}/prime-httpd"
  end

  # cake layers
  %w(skadi loki thor odin tyr).each do |layer|
    # proxy
    runit_service "proxyd-#{layer}" do
      action  :start
      only_if "test -h #{node[:runit][:service_dir]}/proxyd-#{layer}"
    end

    # workers
    (0..(node[:valhalla][:workers][:count] - 1)).step(1).each do |num|
      runit_service "workerd-#{layer}-#{num}" do
        action  :start
        only_if "test -h #{node[:runit][:service_dir]}/workerd-#{layer}-#{num}"
      end
    end
  end

  # make sure everything is working in routing by issuing a request
  execute 'test routing service' do
    action  :run
    user    node[:valhalla][:user][:name]
    command "#{node[:valhalla][:conf_dir]}/health_check.sh #{node[:valhalla][:health_check][:route_action]} #{node[:valhalla][:health_check][:route_request]}"
    only_if "test -h #{node[:runit][:service_dir]}/proxyd-loki"
  end

  # make sure everything is working in elevation by issuing a request
  execute 'test elevation service' do
    action  :run
    user    node[:valhalla][:user][:name]
    command "#{node[:valhalla][:conf_dir]}/health_check.sh 'height' '{\"shape\":[{\"lat\":40.712431, \"lon\":-76.504916}]}'"
    only_if "test -h #{node[:runit][:service_dir]}/proxyd-skadi"
  end
end
