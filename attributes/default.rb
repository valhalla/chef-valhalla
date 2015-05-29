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
default[:valhalla][:lock_dir]                                    = "#{node[:valhalla][:base_dir]}/lock"
default[:valhalla][:extracts_dir]                                = "#{node[:valhalla][:base_dir]}/extracts"

# the repos
default[:valhalla][:github][:base]                               = 'https://github.com/valhalla'
default[:valhalla][:github][:revision]                           = 'master'

# valhalla user to create
default[:valhalla][:user][:name]                                 = 'valhalla'
default[:valhalla][:user][:home]                                 = '/home/valhalla'

# the data to create tiles
default[:valhalla][:extracts]                                    = %w(
  http://download.geofabrik.de/europe/liechtenstein-latest.osm.pbf
)
default[:valhalla][:with_updates]                                = false  # boolean

# where to put fresh tiles and who wants them
default[:valhalla][:bucket]                                      = 'YOUR_BUCKET'
default[:valhalla][:bucket_dir]                                  = 'YOUR_DIR'
default[:valhalla][:service_stack]                               = 'YOUR_STACK_ID'
default[:valhalla][:service_layer]                               = 'YOUR_LAYER_ID'
default[:valhalla][:service_recipes]                             = 'fresh_tiles'

# configuration
default[:valhalla][:config]                                      = "#{node[:valhalla][:conf_dir]}/valhalla.json"
default[:valhalla][:mjolnir][:concurrency]                       = node[:cpu][:total]
default[:valhalla][:httpd][:listen_address]                      = '0.0.0.0'
default[:valhalla][:httpd][:port]                                = 8080

# workers
default[:valhalla][:workers][:count]                             = 8 # int, > 0
