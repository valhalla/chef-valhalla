# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: retile
#

include_recipe 'valhalla::serve'

# create new tiles and restart the server
execute 'retile' do
  action  :nothing
  command 'echo "Re-tiling and then restarting server"'

  # TODO: write tiles to tmp location, then swap them in on server restart
  notifies :run, 'execute[configure tile cutter]', :immediately
  notifies :run, 'execute[cut tiles]', :immediately
  # notifies :run, "execute[publish data deficiencies]", :delayed
  notifies :restart, 'runit_service[tyr-service]', :immediately
end

# grab the lua transforms from the checkout
execute 'configure tile cutter' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "cp -rp #{node[:valhalla][:src_dir]}/mjolnir/conf/osm2pgsql/vertices.lua #{node[:valhalla][:conf_dir]}; \
          cp -rp #{node[:valhalla][:src_dir]}/mjolnir/conf/osm2pgsql/edges.lua #{node[:valhalla][:conf_dir]};"
  cwd     node[:valhalla][:base_dir]
end

# the list of the files we will be importing
files = node[:valhalla][:extracts]
files.map! { |url| url.split('/').last }
extracts = node[:valhalla][:tile_dir] + '/' + files.join(' ' + node[:valhalla][:tile_dir] + '/')

# cut tiles from the data
execute 'cut tiles' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib pbfgraphbuilder -c \
          #{node[:valhalla][:conf_dir]}/#{node[:valhalla][:config]} #{extracts}"
  cwd     node[:valhalla][:base_dir]
end

# TODO: add an execute for publishing the possible data issues to maproulette
# or some other such data correction facility
