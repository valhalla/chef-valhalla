# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: default
#

%w(
  apt::default
  git::default
  valhalla::setup
  valhalla::install
).each do |r|
  include_recipe r
end
