# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: install_from_ppa
#

# remove previous software
execute package_remove do
  action :run
  command '(apt-get purge -y libvalhalla* valhalla* || true) && rm -rf /usr/local/lib/libvalhalla* /usr/local/include/valhalla /usr/local/bin/valhalla*'
end

# update the repository
execute ppa_update do
  action   :run
  command  'apt-get update'
end

# install the packages
execute package_install do
  action :run
  command "apt-get install -y libvalhalla#{node[:valhalla][:ppa_version]}-0 libvalhalla#{node[:valhalla][:ppa_version]}-dev valhalla#{node[:valhalla][:ppa_version]}-bin"
end

# restart the services if they are present
include_recipe 'runit::default'
stop_service do
end
start_service do
end
