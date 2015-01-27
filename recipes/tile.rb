# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: tile
#

# grab some data to cut tiles from
remote_file "#{node[:valhalla][:tile_dir]}/#{node[:valhalla][:data][:file]}" do
  action              :create
  owner               node[:valhalla][:user][:name]
  source              "#{node[:valhalla][:data][:server]}/#{node[:valhalla][:data][:path]}/#{node[:valhalla][:data][:file]}"
  use_conditional_get true
  use_etag            true
  use_last_modified   true

  notifies :run, "execute[configure #{node[:valhalla][:data][:file]}]", :immediately
  notifies :run, "execute[tile #{node[:valhalla][:data][:file]}]", :immediately
  # notifies :run, "execute[publish data deficiencies]", :immediately
end

# grab the lua transforms from the checkout
execute "configure #{node[:valhalla][:data][:file]}" do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "cp -rp #{node[:valhalla][:src_dir]}/mjolnir/conf/osm2pgsql/vertices.lua #{node[:valhalla][:conf_dir]}; \
          cp -rp #{node[:valhalla][:src_dir]}/mjolnir/conf/osm2pgsql/edges.lua #{node[:valhalla][:conf_dir]};"
  cwd     "#{node[:valhalla][:base_dir]}"
end

# cut tiles from the data
execute "tile #{node[:valhalla][:data][:file]}" do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/locla/lib pbfgraphbuilder -c \
          #{node[:valhalla][:conf_dir]}/#{node[:valhalla][:config]} \
          #{node[:valhalla][:tile_dir]}/#{node[:valhalla][:data][:file]}"
  cwd     "#{node[:valhalla][:base_dir]}"
end

# TODO: add an execute for publishing the possible data issues to maproulette
# or some other such data correction facility
