# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: get_elevation_tiles
#

# stop everything from running
execute 'stop service' do
  action      :run
  command     <<-EOH
    service prime-httpd stop
    count=$((#{node[:valhalla][:workers][:count]} - 1))
    service proxyd-skadi stop
    for j in $(seq 0 ${count}); do
      service workerd-skadi-${j} stop
    done
  EOH
  cwd node[:valhalla][:base_dir]

  notifies :run, 'execute[sync tiles]', :immediately
end

# get them from s3
execute 'sync tiles' do
  action  :run
  user    node[:valhalla][:user][:name]
  cwd     node[:valhalla][:src_dir]
  command "skadi/scripts/elevation_extract.sh -180 180 -90 90 #{node[:valhalla][:elevation_dir]} $(($(nproc)*2))"
  timeout 32_000
end

# turn everything back on
include_recipe 'valhalla::_restart'
