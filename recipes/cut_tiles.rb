# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: cut_tiles
#

# use a script to either cut tiles as a one-off or install crontab to do it all the time
execute       'cut_tiles' do
  user        node[:valhalla][:user][:name]
  command     "#{node[:valhalla][:conf_dir]}/cut_tiles.sh >> #{node[:valhalla][:log_dir]}/cut_tiles.log 2>&1"
  cwd         node[:valhalla][:base_dir]
end
