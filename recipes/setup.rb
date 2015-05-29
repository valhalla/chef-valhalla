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
  node[:valhalla][:src_dir],
  node[:valhalla][:lock_dir],
  node[:valhalla][:extracts_dir]
].each do |dir|
  directory dir do
    action    :create
    recursive true
    mode      0755
    owner     node[:valhalla][:user][:name]
  end
end

# move the config file into place
conf_file = File.basename(node[:valhalla][:config])
template "#{node[:valhalla][:config]}" do
  source "#{conf_file}.erb"
  mode   0644
  owner  node[:valhalla][:user][:name]
end

# install all of the scripts for data motion
%w(update_tiles.sh minutely_update.sh push_tiles.py pull_tiles.py).each do |script|
  template "#{node[:valhalla][:conf_dir]}/#{script}" do
    source "#{script}.erb"
    mode   0755
    owner  node[:valhalla][:user][:name]
  end
end

# need a few more deps for data stuff
%w(
  git
  pigz
  python-pip
  jq
  osmosis
  osmctools
).each do |p|
  package p do
    options '--force-yes'
    action :install
  end
end

# need some python deps
%w(
  boto
).each do |p|
  execute p do
    action   :run
    command  "pip install #{p}"
  end
end
