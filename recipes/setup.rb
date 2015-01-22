# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: setup
#

# make a place to do some work
directory node[:valhalla][:basedir] do
  action :create
  recursive true
  mode 0755
  owner node[:valhalla][:user][:name]
end
