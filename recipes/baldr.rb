# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: baldr
#

# clone the repository
deploy "#{node[:valhalla][:basedir]}/baldr" do
  user node[:valhalla][:user][:name]
  repo node[:valhalla][:baldr][:repo]
  revision node[:valhalla][:baldr][:revision]
  enable_submodules true
  shallow_clone true
  symlink_before_migrate.clear

  notifies :run, 'execute[submodules]'
  notifies :run, 'execute[configure baldr]'
  notifies :run, 'execute[install baldr]'
end

# fetch the submodules
execute 'submodules' do
  action :nothing
  command 'git submodule update --init --recursive'
  cwd "#{node[:valhalla][:basedir]}/baldr/current"
end

# configure valhalla::baldr
execute 'configure baldr' do
  action :nothing
  command './autogen.sh && ./configure CPPFLAGS="-DLOGGING_LEVEL_INFO" --with-valhalla-baldr=/usr/local'
  cwd "#{node[:valhalla][:basedir]}/baldr/current"
end

# install valhalla::baldr
execute 'install baldr' do
  action :nothing
  command "make -j#{node[:cpu][:total]} install"
  cwd "#{node[:valhalla][:basedir]}/baldr/current"
end
