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
    aws --region us-east-1 s3 sync s3://#{node[:valhalla][:bucket]}/elevation ./elevation --exclude "*" --include "elevation/*" &> log/download.log
  EOH
  timeout 32_000
end

# turn everything back on
include_recipe 'valhalla::_restart'
