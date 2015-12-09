# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: get_transit_tiles
#

# cut tiles as a one-off
execute 'get transit tiles' do
  user    node[:valhalla][:user][:name]
  cwd     node[:valhalla][:base_dir]
  command <<-EOH
    #{node[:valhalla][:conf_dir]}/cut_transit_tiles.sh >>#{node[:valhalla][:log_dir]}/cut_transit_tiles.log 2>&1
  EOH
  only_if { node[:valhalla][:with_updates] == false && node[:valhalla][:with_transit] == true }
end

# or install crontab to cut tiles all the time
cron 'get transit tiles' do
  user    node[:valhalla][:user][:name]
  day     '*'
  command <<-EOH
    cd #{node[:valhalla][:base_dir]} && #{node[:valhalla][:conf_dir]}/cut_transit_tiles.sh >> #{node[:valhalla][:log_dir]}/cut_transit_tiles.log 2>&1
  EOH
  only_if { node[:valhalla][:with_updates] == true && node[:valhalla][:with_transit] == true }
end
