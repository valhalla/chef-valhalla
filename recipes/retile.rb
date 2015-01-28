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
  notifies :run, "execute[configure #{node[:valhalla][:data][:file]}]", :immediately
  notifies :run, "execute[tile #{node[:valhalla][:data][:file]}]", :immediately
  # notifies :run, "execute[publish data deficiencies]", :delayed
  notifies :restart, 'runit_service[tyr-service]', :immediately
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
  command "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib pbfgraphbuilder -c \
          #{node[:valhalla][:conf_dir]}/#{node[:valhalla][:config]} \
          #{node[:valhalla][:tile_dir]}/#{node[:valhalla][:data][:file]}"
  cwd     "#{node[:valhalla][:base_dir]}"
end

# TODO: add an execute for publishing the possible data issues to maproulette
# or some other such data correction facility
