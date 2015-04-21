# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: retile
#

include_recipe 'valhalla::serve'
include_recipe 'valhalla::minutely_update'

# create new tiles with latest pbf and restart the server
execute 'retile' do
  action  :nothing
  command 'echo "Re-tiling and then restarting server"'

  # TODO: write tiles to tmp location, then swap them in on server restart
  notifies :run,      'execute[minutely_update]',           :immediately
  notifies :run,      'execute[clean mjolnir tiles]',       :immediately
  notifies :run,      'execute[cut tiles]',                 :immediately
  notifies :run,      'execute[backup tyr tiles]',          :immediately
  notifies :run,      'execute[clean tyr tiles]',           :immediately
  notifies :run,      'execute[move tiles]',                :immediately
  notifies :run,      'execute[clean backup tiles]',        :immediately
  # notifies :run,     'execute[publish data deficiencies]', :immediately
  notifies :restart,  'runit_service[tyr-service]',         :immediately
end

# clean mjolnir tiles
execute 'clean mjolnir tiles' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "rm -rf #{node[:valhalla][:mjolnir_tile_dir]}/*"
  cwd     node[:valhalla][:base_dir]
end

# clean tyr tiles
execute 'clean tyr tiles' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "rm -rf #{node[:valhalla][:tile_dir]}/*"
  cwd     node[:valhalla][:base_dir]
end

# backup tyr tiles
execute 'backup tyr tiles' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "#{node[:valhalla][:src_dir]}/mjolnir/scripts/backup_tiles.sh #{node[:valhalla][:tile_dir]}"
  cwd     node[:valhalla][:base_dir]
end

# clean backup tiles
execute 'clean backup tiles' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "#{node[:valhalla][:src_dir]}/mjolnir/scripts/clean_tiles.sh #{node[:valhalla][:tile_dir]} 2"
  cwd     node[:valhalla][:base_dir]
end

# move the newly created tiles to the tyr dir
execute 'move tiles' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "mv #{node[:valhalla][:mjolnir_tile_dir]}/* #{node[:valhalla][:tile_dir]}/"
  cwd     node[:valhalla][:base_dir]
end

# the list of the files we will be importing
files = node[:valhalla][:extracts].map { |url| url.split('/').last }
extracts = node[:valhalla][:extracts_dir] + '/' + files.join(' ' + node[:valhalla][:extracts_dir] + '/')

# cut tiles from the data
execute 'cut tiles' do
  action   :nothing
  user     node[:valhalla][:user][:name]
  command  "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib pbfgraphbuilder -c \
           #{node[:valhalla][:conf_dir]}/#{node[:valhalla][:mjolnir][:config]} #{extracts}"
  cwd      node[:valhalla][:base_dir]
  timeout  node[:valhalla][:tiles][:cut_tiles_timeout]
end

# TODO: add an execute for publishing the possible data issues to maproulette
# or some other such data correction facility
