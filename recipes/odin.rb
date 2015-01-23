# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: odin
#

# clone the repository
deploy "#{node[:valhalla][:basedir]}/odin" do
  user node[:valhalla][:user][:name]
  repo node[:valhalla][:odin][:repo]
  revision node[:valhalla][:odin][:revision]
  enable_submodules true
  shallow_clone true
  symlink_before_migrate.clear

  notifies :run, 'execute[submodules]'
  notifies :run, 'execute[configure odin]'
  notifies :run, 'execute[install odin]'
end

# fetch the submodules
execute 'submodules' do
  action :nothing
  command 'git submodule update --init --recursive'
  cwd "#{node[:valhalla][:basedir]}/odin/current"
end

# configure valhalla::odin
execute 'configure odin' do
  action :nothing
  command './autogen.sh && ./configure CPPFLAGS="-DLOGGING_LEVEL_INFO" --with-valhalla-odin=/usr/local --with-valhalla-baldr=/usr/local'
  cwd "#{node[:valhalla][:basedir]}/odin/current"
end

# install valhalla::odin
execute 'install odin' do
  action :nothing
  command "make -j#{node[:cpu][:total]} install"
  cwd "#{node[:valhalla][:basedir]}/odin/current"
end
