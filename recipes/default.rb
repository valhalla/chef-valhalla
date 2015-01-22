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
).each do |r|
  include_recipe r
end

#  valhalla::baldr
#  valhalla::mjolnir
#  valhalla::loki
#  valhalla::odin
#  valhalla::thor
#  valhalla::tyr
#  valhalla::make_tiles
#  valhalla::serve
