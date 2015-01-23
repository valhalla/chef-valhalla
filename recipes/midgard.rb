# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: midgard
#

# add c++11 ppa
apt_repository 'ubuntu-toolchain-r' do
  uri 'http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  # keyserver 'keyserver.ubuntu.com'
  # key ''
end

# dev packages required
%w(
  autoconf
  automake
  libtool
  make
  gcc-4.8
  g++-4.8
).each do |p|
  package p do
    options "--force-yes"
    action :install
  end
end

# clone the repository
deploy "#{node[:valhalla][:basedir]}/midgard" do
  user node[:valhalla][:user][:name]
  repo node[:valhalla][:midgard][:repo]
  revision node[:valhalla][:midgard][:revision]
  symlink_before_migrate.clear

  notifies :run, 'execute[configure midgard]'
  notifies :run, 'execute[install midgard]'
end

# configure valhalla::midgard
execute 'configure midgard' do
  action :nothing
  command './autogen.sh && ./configure CPPFLAGS="-03 -DLOGGING_LEVEL_INFO"'
  cwd "#{node[:valhalla][:basedir]}/midgard/current"
end

# install valhalla::midgard
execute 'install midgard' do
  action :nothing
  command "make -j#{node[:cpu][:total]} install"
  cwd "#{node[:valhalla][:basedir]}/midgard/current"
end
