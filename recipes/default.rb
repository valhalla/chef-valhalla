# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: default
#

include_recipe 'apt::default'

package 'git'

%w(
  user::default
  valhalla::install
).each do |r|
  include_recipe r
end
