# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Attributes:: default
#

# where to do some install work
default[:valhalla][:base_dir]              = '/opt/valhalla'
default[:valhalla][:tile_dir]              = "#{default[:valhalla][:base_dir]}/tiles"
default[:valhalla][:log_dir]               = "#{default[:valhalla][:base_dir]}/log"
default[:valhalla][:conf_dir]              = "#{default[:valhalla][:base_dir]}/etc"
default[:valhalla][:src_dir]               = "#{default[:valhalla][:base_dir]}/src"

# the repos
default[:valhalla][:github][:base]         = 'https://github.com/valhalla'
default[:valhalla][:github][:repos]        = %w(midgard baldr mjolnir loki odin thor tyr)
default[:valhalla][:github][:revision]     = 'master'

# valhalla user to create
default[:valhalla][:user][:name]           = 'valhalla'
default[:valhalla][:user][:home]           = '/home/valhalla'

# the data to create tiles
default[:valhalla][:extracts]              = %w(http://download.geofabrik.de/europe/liechtenstein-latest.osm.pbf)
# configuration
default[:valhalla][:config]                = 'valhalla.json'
