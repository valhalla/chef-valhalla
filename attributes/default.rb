# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Attributes:: default
#

# where to do some install work
default[:valhalla][:base_dir]                                    = '/opt/valhalla'
default[:valhalla][:tile_dir]                                    = "#{node[:valhalla][:base_dir]}/tiles"
default[:valhalla][:log_dir]                                     = "#{node[:valhalla][:base_dir]}/log"
default[:valhalla][:conf_dir]                                    = "#{node[:valhalla][:base_dir]}/etc"
default[:valhalla][:src_dir]                                     = "#{node[:valhalla][:base_dir]}/src"
default[:valhalla][:extracts_dir]                                = "#{node[:valhalla][:base_dir]}/extracts"

# the repos
default[:valhalla][:github][:base]                               = 'https://github.com/valhalla'
default[:valhalla][:github][:repos]                              = %w(midgard baldr sif mjolnir loki odin thor tyr)
default[:valhalla][:github][:revision]                           = 'master'

# valhalla user to create
default[:valhalla][:user][:name]                                 = 'valhalla'
default[:valhalla][:user][:home]                                 = '/home/valhalla'

# the data to create tiles
default[:valhalla][:extracts]                                    = %w(
  http://download.geofabrik.de/europe/liechtenstein-latest.osm.pbf
)

# configuration
default[:valhalla][:config]                                      = 'valhalla.json'
default[:valhalla][:log][:mjolnir]                               = "#{node[:valhalla][:log_dir]}/mjolnir.log"
default[:valhalla][:log][:thor]                                  = "#{node[:valhalla][:log_dir]}/thor.log"
default[:valhalla][:log][:tyr]                                   = "#{node[:valhalla][:log_dir]}/tyr.log"
default[:valhalla][:mjolnir][:concurrency]                       = node[:cpu][:total]

# retile
default[:valhalla][:retile][:cut_tiles_timeout]                  = 86_400 # 24 hours
