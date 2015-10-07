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
default[:valhalla][:temp_dir]                                    = "#{node[:valhalla][:base_dir]}/temp"
default[:valhalla][:src_dir]                                     = "#{node[:valhalla][:base_dir]}/src"
default[:valhalla][:lock_dir]                                    = "#{node[:valhalla][:base_dir]}/lock"
default[:valhalla][:extracts_dir]                                = "#{node[:valhalla][:base_dir]}/extracts"
default[:valhalla][:elevation_dir]                               = "#{node[:valhalla][:base_dir]}/elevation"

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
default[:valhalla][:routing_service_stack]                       = 'YOUR_STACK_ID'
default[:valhalla][:routing_service_layer]                       = 'YOUR_LAYER_ID'
default[:valhalla][:routing_service_elb]                         = 'YOUR_ELB_NAME'
default[:valhalla][:routing_service_recipes]                     = 'valhalla::get_routing_tiles'
default[:valhalla][:min_routing_service_update_instances]        = 2
default[:valhalla][:health_check_timeout]                        = 300

# configuration
default[:valhalla][:config]                                      = "#{node[:valhalla][:conf_dir]}/valhalla.json"
default[:valhalla][:max_cache_size]                              = "#{node.opsworks.layers.'data-producer' and node.opsworks.instance.layers.include?('data-producer') ? 1024*1024*1024 : ((node.memory.total.to_f / (node.cpu.total.to_f * 2)) * 0.9).floor * 1024}"
default[:valhalla][:mjolnir][:concurrency]                       = node[:cpu][:total]
default[:valhalla][:httpd][:listen_address]                      = '0.0.0.0'
default[:valhalla][:httpd][:port]                                = 8080

# workers
default[:valhalla][:workers][:count]                             = node[:cpu][:total]
