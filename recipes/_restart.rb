# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: _restart
#

include_recipe 'runit::default'

# httpd
runit_service 'prime-httpd' do
  action  :restart
  only_if "test -d #{node[:runit][:sv_dir]}/prime-httpd"
end

# cake layers
%w(loki thor odin tyr).each do |layer|
  # proxy
  runit_service "proxyd-#{layer}" do
    action  :restart
    only_if "test -d #{node[:runit][:sv_dir]}/proxyd-#{layer}"
  end

  # workers
  (0..(node[:valhalla][:workers][:count] - 1)).step(1).each do |num|
    runit_service "workerd-#{layer}-#{num}" do
      action  :restart
      only_if "test -d #{node[:runit][:sv_dir]}/workerd-#{layer}-#{num}"
    end
  end
end
