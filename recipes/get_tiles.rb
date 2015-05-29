# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: fresh_tiles
#

execute 'pull_tiles' do
  action      :run
  user        node[:valhalla][:user][:name]
  command     "$(#{node[:valhalla][:conf_dir]}/pull_tiles.py) > latest_tiles.txt; wget $(cat latest_tiles.txt)"
  cwd         node[:valhalla][:base_dir]

  notifies :run, 'execute[extract tiles]', :immediately
  notifies :run, 'execute[stop workers]', :immediately
  notifies :run, 'execute[move tiles]', :immediately
  notifies :run, 'execute[start workers]', :immediately
end

execute 'extract tiles' do
  action      :run
  user        node[:valhalla][:user][:name]
  command     'rm -rf tmp_tiles; mkdir tmp_tiles; tar pxvf $(basename $(cat latest_tiles.txt)) -C tmp_tiles; rm $(basename $(cat latest_tiles.txt))'
  cwd         node[:valhalla][:base_dir]
end

execute 'stop workers' do
  action      :run
  command     "for i in loki thor odin tyr; do for j in {0..#{node[:valhalla][:workers][:count]}}; do service stop workerd-$i-$j; done; done"
  cwd         node[:valhalla][:base_dir]
end

execute 'move tiles' do
  action      :run
  user        node[:valhalla][:user][:name]
  command     "rm -rf #{node[:valhalla][:tile_dir]}; mv tmp_tiles #{node[:valhalla][:tile_dir]}"
  cwd         node[:valhalla][:base_dir]
end

execute 'start workers' do
  action      :run
  command     "for i in loki thor odin tyr; do for j in {0..#{node[:valhalla][:workers][:count]}}; do service start workerd-$i-$j; done; done"
  cwd         node[:valhalla][:base_dir]
end
