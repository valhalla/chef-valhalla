# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: get_routing_tiles
#

# stop everything from running
execute 'stop service' do
  action      :run
  command     <<-EOH
    service prime-httpd stop
    count=$((#{node[:valhalla][:workers][:count]} - 1))
    for i in loki thor odin tyr; do
      service proxyd-${i} stop
      for j in $(seq 0 ${count}); do
        service workerd-${i}-${j} stop
      done
    done
  EOH
  cwd node[:valhalla][:base_dir]

  notifies :run, 'execute[pull tiles]', :immediately
  notifies :run, 'execute[extract tiles]', :immediately
  notifies :run, 'execute[move tiles]', :immediately
end

# go get the tiles
execute 'pull tiles' do
  action  :run
  user    node[:valhalla][:user][:name]
  cwd     node[:valhalla][:base_dir]
  command <<-EOH
    echo -n https://s3.amazonaws.com/#{node[:valhalla][:bucket]}/#{node[:valhalla][:bucket_dir]}/ > latest_tiles.txt &&
    aws --region us-east-1 s3 ls s3://#{node[:valhalla][:bucket]}/#{node[:valhalla][:bucket_dir]}/ | grep -F tiles_ | awk '{print $4}' | sort | tail -n 1 >> latest_tiles.txt
  EOH
end

# open them up
execute 'extract tiles' do
  action  :run
  user    node[:valhalla][:user][:name]
  cwd     node[:valhalla][:base_dir]
  command <<-EOH
    rm -rf tmp_tiles old_tiles &&
    mkdir tmp_tiles &&
    curl $(cat latest_tiles.txt) 2>#{node[:valhalla][:log_dir]}/curl_tiles.log | tar xzp -C tmp_tiles 2>#{node[:valhalla][:log_dir]}/untar_tiles.log
  EOH
  retries 3
end

# move them into place
execute 'move tiles' do
  action  :run
  user    node[:valhalla][:user][:name]
  command "mv #{node[:valhalla][:tile_dir]} old_tiles; mv tmp_tiles #{node[:valhalla][:tile_dir]}"
  cwd     node[:valhalla][:base_dir]
end

# turn everything back on
include_recipe 'valhalla::_restart'
