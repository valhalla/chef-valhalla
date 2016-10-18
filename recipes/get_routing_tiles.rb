# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: get_routing_tiles
#

# stop everything from running, while we get new tiles
include_recipe 'runit::default'
stop_service do
  notifies :run, 'execute[sync tiles]', :immediately
end

# get them from s3
execute 'sync tiles' do
  action  :run
  user    node[:valhalla][:user][:name]
  cwd     node[:valhalla][:base_dir]
  command <<-EOH
    echo -n s3://#{node[:valhalla][:bucket]}/#{node[:valhalla][:bucket_dir]}/ > latest_tiles.txt &&
    aws --region us-east-1 s3 ls $(cat latest_tiles.txt) | grep -F planet_ | awk '{print $4}' | sort | tail -n 1 >> latest_tiles.txt &&
    aws --region us-east-1 s3 cp $(cat latest_tiles.txt) planet.tar
  EOH
end

# turn everything back on
start_service do
end
