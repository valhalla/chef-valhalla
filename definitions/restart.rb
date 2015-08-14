# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Definition:: restart_service
#

define :restart_service do
  # httpd
  runit_service 'prime-httpd' do
    action  :restart
    only_if "test -h #{node[:runit][:service_dir]}/prime-httpd"
  end

  # cake layers
  %w(skadi loki thor odin tyr).each do |layer|
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

  # make sure everything is working in routing by issuing a request
  execute 'test routing service' do
    action  :run
    user    node[:valhalla][:user][:name]
    command "#{node[:valhalla][:conf_dir]}/health_check.sh 'route' '{\"locations\":[{\"lat\":40.402918,\"lon\":-76.535017},{\"lat\":40.403654,\"lon\": -76.529846}],\"costing\":\"auto\"}'"
    only_if "test -h #{node[:runit][:service_dir]}/proxyd-loki"
  end

  # make sure everything is working in elevation by issuing a request
  execute 'test elevation service' do
    action  :run
    user    node[:valhalla][:user][:name]
    command "#{node[:valhalla][:conf_dir]}/health_check.sh 'elevation' '{\"shape\":[{\"lat\":40.712431, \"lon\":-76.504916}]}'"
    only_if "test -h #{node[:runit][:service_dir]}/proxyd-skadi"
  end
end
