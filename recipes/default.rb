# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: default
#

%w(
  user::default
  apt::default
  git::default
  valhalla::setup
  valhalla::install
  valhalla::data
).each do |r|
  include_recipe r
end
