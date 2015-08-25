# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: get_elevation_tiles
#

include_recipe 'runit::default'

# stop everything from running
stop_service do
  notifies :run, 'execute[sync tiles]', :immediately
end

# get them from s3
execute 'sync tiles' do
  action  :run
  user    node[:valhalla][:user][:name]
  cwd     node[:valhalla][:src_dir]
  command "skadi/scripts/elevation_extract.sh -180 180 -90 90 #{node[:valhalla][:elevation_dir]} $(($(nproc)*2)) 2>&1 >> #{node[:valhalla][:log_dir]}/elevation_tiles.log"
  retries 3
  timeout 32_000
end

# turn everything back on
start_service do
end
