# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Attributes:: default
#

# where to do some install work
default[:valhalla][:base_dir]           = '/opt/valhalla'
default[:vatallla][:tile_dir]           = "#{default[:valhalla][:base_dir]}/tiles"
default[:valhalla][:config]             = 'valhalla.json'

# the repos
default[:valhalla][:github][:base]      = 'https://github.com/valhalla'
default[:valhalla][:github][:repos]     = %w(midgard baldr mjolnir loki odin thor tyr)
default[:valhalla][:github][:revision]  = 'master'

# valhalla user to create
default[:valhalla][:user][:name]        = 'valhalla'
default[:valhalla][:user][:home]        = '/home/valhalla'

# the data to create tiles
default[:valhalla][:data][:server]      = 'http://download.geofabrik.de'
default[:valhalla][:data][:file]        = 'europe/liechtenstein-latest.osm.pbf'
