# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: mjolnir
#

# clone the repository
deploy "#{node[:valhalla][:basedir]}/mjolnir" do
  user node[:valhalla][:user][:name]
  repo node[:valhalla][:mjolnir][:repo]
  revision node[:valhalla][:mjolnir][:revision]
  enable_submodules true
  shallow_clone true
  symlink_before_migrate.clear

  notifies :run, 'execute[submodules]'
  notifies :run, 'execute[configure mjolnir]'
  notifies :run, 'execute[install mjolnir]'
end

# fetch the submodules
execute 'submodules' do
  action :nothing
  command 'git submodule update --init --recursive'
  cwd "#{node[:valhalla][:basedir]}/mjolnir/current"
end

# configure valhalla::mjolnir
execute 'configure mjolnir' do
  action :nothing
  command './autogen.sh && ./configure CPPFLAGS="-DLOGGING_LEVEL_INFO" --with-valhalla-mjolnir=/usr/local --with-valhalla-baldr=/usr/local'
  cwd "#{node[:valhalla][:basedir]}/mjolnir/current"
end

# install valhalla::mjolnir
execute 'install mjolnir' do
  action :nothing
  command "make -j#{node[:cpu][:total]} install"
  cwd "#{node[:valhalla][:basedir]}/mjolnir/current"
end
