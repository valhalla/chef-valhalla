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
  node[:valhalla][:extracts_dir],
  node[:valhalla][:temp_dir],
  node[:valhalla][:elevation_dir],
  node[:valhalla][:test_dir],
  node[:valhalla][:test_requests],
  node[:valhalla][:test_results]
].each do |dir|
  directory dir do
    action    :create
    recursive true
    mode      0755
    owner     node[:valhalla][:user][:name]
  end
end

# move the valhalla config file into place
conf_file = File.basename(node[:valhalla][:config])
template node[:valhalla][:config] do
  source "#{conf_file}.erb"
  mode   0644
  owner  node[:valhalla][:user][:name]
end

# move the maproulette config file into place
conf_file = File.basename(node[:maproulette][:config])
template node[:maproulette][:config] do
  source "#{conf_file}.erb"
  mode   0644
  owner  node[:valhalla][:user][:name]
end

# install all of the scripts for data motion
%w(cut_tiles.sh get_transit_tiles.sh minutely_update.sh push_tiles.py health_check.sh map_roulette.py).each do |script|
  template "#{node[:valhalla][:conf_dir]}/#{script}" do
    source "#{script}.erb"
    mode   0755
    owner  node[:valhalla][:user][:name]
  end
end

# install all of the scripts for testing
%w(batch.sh run.sh test_tiles.sh).each do |script|
  template "#{node[:valhalla][:test_dir]}/#{script}" do
    source "#{script}.erb"
    mode   0755
    owner  node[:valhalla][:user][:name]
  end
end

# install all of the test requests
%w(transit_dev_routes.tmpl transit_prod_routes.tmpl).each do |script|
  template "#{node[:valhalla][:test_requests]}/#{script}" do
    source "#{script}.erb"
    mode   0755
    owner  node[:valhalla][:user][:name]
  end
end

# a few things from ppa
%w(ppa:kevinkreiser/prime-server ppa:valhalla-routing/valhalla).each do |ppa|
  execute ppa do
    action   :run
    command  "apt-add-repository -y #{ppa} && apt-get update"
  end
end

# need a few more deps
%w(
  software-properties-common
  git
  pigz
  python-pip
  jq
  parallel
  sendmail
  osmosis
  osmctools
  autoconf
  automake
  spatialite-bin
  autotools-dev
  pkg-config
  vim-common
  locales
  libboost1.54-all-dev
  libcurl4-openssl-dev
  libgeos-dev
  libgeos++-dev
  lua5.2
  liblua5.2-dev
  libprime-server-dev
  libprotobuf-dev
  libspatialite-dev
  libsqlite3-dev
  protobuf-compiler
  libboost-filesystem1.54.0
  libboost-regex1.54.0
  libboost-system1.54.0
  libboost-thread1.54.0
  liblua5.2-0
  libprime-server0
  libspatialite5
  libspatialite-dev
  libsqlite3-0
  libprotobuf8
  libcurl3
  libgeos-3.4.2
  libgeos-c1
  prime-server-bin
).each do |p|
  package p do
    options '--force-yes'
    action :install
  end
end

# need some python deps
%w(
  boto
  filechunkio
  awscli==1.6.9
  requests
).each do |p|
  execute p do
    action   :run
    command  "pip install #{p}"
  end
end

# logrotate
template '/etc/logrotate.d/valhalla' do
  source  'logrotate.erb'
  owner   'root'
  group   'root'
  mode    0644
end
