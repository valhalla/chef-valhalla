# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: loki
#

# clone the repository
deploy "#{node[:valhalla][:basedir]}/loki" do
  user node[:valhalla][:user][:name]
  repo node[:valhalla][:loki][:repo]
  revision node[:valhalla][:loki][:revision]
  enable_submodules true
  shallow_clone true
  symlink_before_migrate.clear

  notifies :run, 'execute[submodules]'
  notifies :run, 'execute[configure loki]'
  notifies :run, 'execute[install loki]'
end

# fetch the submodules
execute 'submodules' do
  action :nothing
  command 'git submodule update --init --recursive'
  cwd "#{node[:valhalla][:basedir]}/loki/current"
end

# configure valhalla::loki
execute 'configure loki' do
  action :nothing
  command './autogen.sh && ./configure CPPFLAGS="-DLOGGING_LEVEL_INFO" --with-valhalla-loki=/usr/local --with-valhalla-baldr=/usr/local'
  cwd "#{node[:valhalla][:basedir]}/loki/current"
end

# install valhalla::loki
execute 'install loki' do
  action :nothing
  command "make -j#{node[:cpu][:total]} install"
  cwd "#{node[:valhalla][:basedir]}/loki/current"
end
