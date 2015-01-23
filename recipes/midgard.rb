# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: midgard
#

# clone the repository
deploy "#{node[:valhalla][:basedir]}/midgard" do
  user node[:valhalla][:user][:name]
  repo node[:valhalla][:midgard][:repo]
  revision node[:valhalla][:midgard][:revision]
  enable_submodules true
  shallow_clone true
  symlink_before_migrate.clear

  notifies :run, 'execute[submodules]'
  notifies :run, 'execute[configure midgard]'
  notifies :run, 'execute[install midgard]'
end

# fetch the submodules
execute 'submodules' do
  action :nothing
  command 'git submodule update --init --recursive'
  cwd "#{node[:valhalla][:basedir]}/midgard/current"
end

# configure valhalla::midgard
execute 'configure midgard' do
  action :nothing
  command './autogen.sh && ./configure CPPFLAGS="-DLOGGING_LEVEL_INFO"'
  cwd "#{node[:valhalla][:basedir]}/midgard/current"
end

# install valhalla::midgard
execute 'install midgard' do
  action :nothing
  command "make -j#{node[:cpu][:total]} install"
  cwd "#{node[:valhalla][:basedir]}/midgard/current"
end
