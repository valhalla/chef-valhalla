# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: setup
#

user_account node[:valhalla][:user][:name] do
  manage_home   true
  create_group  true
  ssh_keygen    false
  home          node[:valhalla][:user][:home]
  not_if        { node[:valhalla][:user][:name] == 'root' }
end

directory node[:valhalla][:basedir] do
  action    :create
  recursive true
  mode      0755
  owner     node[:valhalla][:user][:name]
end
