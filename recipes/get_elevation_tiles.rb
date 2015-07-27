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

  notifies :run, 'execute[extract tiles]', :immediately
end

# open them up
execute 'extract tiles' do
  action  :run
  user    node[:valhalla][:user][:name]
  cwd     node[:valhalla][:base_dir]
  command <<-EOH
    rm -rf elevation &&
    mkdir elevation &&
    wget -O - #{node[:valhalla][:elevation_url]} 2>#{node[:valhalla][:log_dir]}/download.log | tar xzp -C elevation
  EOH
  timeout 32_000
end

# turn everything back on
include_recipe 'valhalla::_restart'
