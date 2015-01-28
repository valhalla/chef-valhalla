# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: setup
#

# make the valhalla user
user_account node[:valhalla][:user][:name] do
  manage_home   true
  create_group  true
  ssh_keygen    false
  home          node[:valhalla][:user][:home]
  not_if        { node[:valhalla][:user][:name] == 'root' }
end

# make a few places to work in
[
  node[:valhalla][:base_dir],
  node[:valhalla][:tile_dir],
  node[:valhalla][:log_dir],
  node[:valhalla][:conf_dir],
  node[:valhalla][:src_dir]
].each do |dir|
  directory dir do
    action    :create
    recursive true
    mode      0755
    owner     node[:valhalla][:user][:name]
  end
end

# move the config file into place
template "#{node[:valhalla][:conf_dir]}/#{node[:valhalla][:config]}" do
  source "#{node[:valhalla][:config]}.erb"
  mode   0644
  owner  node[:valhalla][:user][:name]

  notifies :run, 'execute[retile]', :delayed
end

# install all the deps
%w(
  autoconf
  automake
  libtool
  make
  gcc-4.8
  g++-4.8
  libpython2.7-dev
  libboost1.54-dev
  libboost-python1.54-dev
  libboost-program-options1.54-dev
  libboost-filesystem1.54-dev
  libboost-system1.54-dev
  protobuf-compiler
  libprotobuf-dev
  lua5.2
  liblua5.2-dev
).each do |p|
  package p do
    options '--force-yes'
    action  :install
  end
end

# update alternatives
bash 'update alternatives' do
  code <<-EOH
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 90;
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 90;
  EOH
end
