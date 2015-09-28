# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: _stop
#

# stop everything from running
include_recipe 'runit::default'
stop_service do
end
