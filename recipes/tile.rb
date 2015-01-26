# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: tile
#

# grab some data to cut tiles from
remote_file "#{node[:vatallla][:data][:tile_dir]}/#{node[:valhalla][:data][:file]}" do
  action              :create
  owner               node[:valhalla][:user][:name]
  source              "#{node[:valhalla][:data][:server]}/#{node[:valhalla][:data][:file]}"
  use_conditional_get true
  use_etag            true
  use_last_modified   true

  # notifies :run, "execute[tile #{node[:valhalla][:data][:file]}]", :immediately
  # notifies :run, "execute[publish data deficiencies]", :immediately
end

# cut tiles from the data
execute "tile #{node[:valhalla][:data][:file]}" do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "pbfgraphbuilder -c #{node[:vatallla][:data][:base_dir]}/conf/tiles.json \
          #{node[:vatallla][:data][:tile_dir]}/#{node[:valhalla][:data][:file]}"
  cwd     "#{node[:valhalla][:base_dir]}/#{repo}"
end

# TODO: add an execute for publishing the possible data issues to maproulette
# or some other such data correction facility
