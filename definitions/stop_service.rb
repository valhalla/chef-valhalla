# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Definition:: stop_service
#

define :stop_service do
  # httpd
  runit_service 'prime-httpd' do
    action  :stop
    only_if "test -h #{node[:runit][:service_dir]}/prime-httpd"
  end

  # cake layers
  %w(skadi loki thor odin tyr).each do |layer|
    # proxy
    runit_service "proxyd-#{layer}" do
      action  :stop
      only_if "test -h #{node[:runit][:service_dir]}/proxyd-#{layer}"
    end

    # workers
    (0..(node[:valhalla][:workers][:count] - 1)).step(1).each do |num|
      runit_service "workerd-#{layer}-#{num}" do
        action  :stop
        only_if "test -h #{node[:runit][:service_dir]}/workerd-#{layer}-#{num}"
      end
    end
  end
end
