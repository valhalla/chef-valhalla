# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: default
#

%w(
  user::default
  apt::default
  git::default
  runit::default
  valhalla::setup
  valhalla::install
  valhalla::tile
  valhalla::serve
).each do |r|
  include_recipe r
end
