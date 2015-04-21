# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: freshtiles
#

include_recipe 'valhalla::serve'

# create new tiles with latest pbf and restart the server
execute 'freshtiles' do
  action  :nothing
  command 'echo "Tiling with latest pbf and restarting server"'

  # TODO: write tiles to tmp location, then swap them in on server restart
  # notifies :create,  'execute[resource]',              'immediately'
  notifies :create,   'link[vertices config]',              :immediately
  notifies :create,   'link[edges config]',                 :immediately
  notifies :create,   'link[admins config]',                :immediately
  notifies :run,      'execute[clean mjolnir tiles]',       :immediately
  notifies :run,      'execute[create admins]',             :immediately
  notifies :run,      'execute[cut tiles]',                 :immediately
  notifies :run,      'execute[clean tyr tiles]',           :immediately
  notifies :run,      'execute[move tiles]',                :immediately
  notifies :run,      'execute[clean up]',                  :immediately
  # notifies :run,     'execute[publish data deficiencies]', :immediately
  notifies :restart,  'runit_service[tyr-service]',         :immediately
end

# link the lua transforms from the checkout
%w(vertices edges admins).each do |lua|
  link "#{lua} config" do
    action      :nothing
    owner       node[:valhalla][:user][:name]
    target_file "#{node[:valhalla][:conf_dir]}/#{lua}.lua"
    to          "#{node[:valhalla][:src_dir]}/mjolnir/conf/#{lua}.lua"
  end
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

# clean up
execute 'clean up' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command 'rm -rf *.bin'
  cwd     node[:valhalla][:base_dir]
end

# move the newly created tiles to the tyr dir
execute 'move tiles' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "mv #{node[:valhalla][:mjolnir_tile_dir]}/* #{node[:valhalla][:tile_dir]}/"
  cwd     node[:valhalla][:base_dir]
end

# move the admin log
execute 'move admin log' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "mv #{node[:valhalla][:log][:mjolnir]} #{node[:valhalla][:log][:mjolnir]}.admins"
  cwd     node[:valhalla][:base_dir]
end

# the list of the files we will be importing
files = node[:valhalla][:extracts].map { |url| url.split('/').last }
extracts = node[:valhalla][:extracts_dir] + '/' + files.join(' ' + node[:valhalla][:extracts_dir] + '/')

# create the admins from the data
# TODO:  This will be removed when we thread admins in mjolnir.
execute 'create admins' do
  action   :nothing
  user     node[:valhalla][:user][:name]
  command  "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib pbfadminbuilder -c \
           #{node[:valhalla][:conf_dir]}/#{node[:valhalla][:mjolnir][:config]} #{extracts}"
  cwd      node[:valhalla][:base_dir]
  timeout  node[:valhalla][:tiles][:cut_tiles_timeout]
  notifies :run,      'execute[move admin log]',                :immediately
end

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
