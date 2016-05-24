# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: get_transit_tiles
#

# get transit tiles as a one-off
execute 'get transit tiles' do
  user    node[:valhalla][:user][:name]
  cwd     node[:valhalla][:base_dir]
  command <<-EOH
    #{node[:valhalla][:conf_dir]}/get_transit_tiles.sh >>#{node[:valhalla][:log_dir]}/transit.log 2>&1
  EOH
  only_if { node[:valhalla][:with_transit] == true }
end

# or install crontab to get transit tiles all the time
cron 'get transit tiles' do
  user    node[:valhalla][:user][:name]
  minute  '0'
  hour    '3'
  weekday '6'
  command <<-EOH
    cd #{node[:valhalla][:base_dir]} && #{node[:valhalla][:conf_dir]}/get_transit_tiles.sh >> #{node[:valhalla][:log_dir]}/transit.log 2>&1
  EOH
  only_if { node[:valhalla][:with_updates] == true && node[:valhalla][:with_transit] == true }
end
