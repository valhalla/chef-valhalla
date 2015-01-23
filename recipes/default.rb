# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: default
#

%w(
  apt::default
  git::default
  valhalla::setup
  valhalla::midgard
  valhalla::baldr
  valhalla::loki
  valhalla::mjolnir
  valhalla::odin
  valhalla::thor
  valhalla::tyr
).each do |r|
  include_recipe r
end
