# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: _restart
#

# stop everything from running
include_recipe 'runit::default'
stop_service do
end

# turn everything back on
start_service do
end
