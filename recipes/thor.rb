# -*- cthorg: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: thor
#

# clone the repository
deploy "#{node[:valhalla][:basedir]}/thor" do
  user node[:valhalla][:user][:name]
  repo node[:valhalla][:thor][:repo]
  revision node[:valhalla][:thor][:revision]
  enable_submodules true
  shallow_clone true
  symlink_before_migrate.clear

  notifies :run, 'execute[submodules]'
  notifies :run, 'execute[configure thor]'
  notifies :run, 'execute[install thor]'
end

# fetch the submodules
execute 'submodules' do
  action :nothing
  command 'git submodule update --init --recursive'
  cwd "#{node[:valhalla][:basedir]}/thor/current"
end

# configure valhalla::thor
execute 'configure thor' do
  action :nothing
  command './autogen.sh && ./configure CPPFLAGS="-DLOGGING_LEVEL_INFO" --with-valhalla-thor=/usr/local --with-valhalla-baldr=/usr/local --with-valhalla-loki=/usr/local --with-valhalla-odin=/usr/local'
  cwd "#{node[:valhalla][:basedir]}/thor/current"
end

# install valhalla::thor
execute 'install thor' do
  action :nothing
  command "make -j#{node[:cpu][:total]} install"
  cwd "#{node[:valhalla][:basedir]}/thor/current"
end
