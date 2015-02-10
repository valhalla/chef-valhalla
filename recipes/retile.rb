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
  # notifies :create,   'sometempdir[resource]',              'immediately'
  notifies :create,   'link[vertices config]',              :immediately
  notifies :create,   'link[edges config]',                 :immediately
  notifies :run,      'execute[clean tiles]',               :immediately
  notifies :run,      'execute[cut tiles]',                 :immediately
  # notifies :run,      'execute[publish data deficiencies]', :immediately
  notifies :restart,  'runit_service[tyr-service]',         :immediately
end

# link the lua transforms from the checkout
%w(vertices edges).each do |lua|
  link "#{lua} config" do
    action      :nothing
    owner       node[:valhalla][:user][:name]
    target_file "#{node[:valhalla][:conf_dir]}/#{lua}.lua"
    to          "#{node[:valhalla][:src_dir]}/mjolnir/conf/#{lua}.lua"
  end
end

execute 'clean tiles' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "rm -rf #{node[:valhalla][:tile_dir]}/*"
  cwd     node[:valhalla][:base_dir]
end

# the list of the files we will be importing
files = node[:valhalla][:extracts].map { |url| url.split('/').last }
extracts = node[:valhalla][:extracts_dir] + '/' + files.join(' ' + node[:valhalla][:extracts_dir] + '/')

# cut tiles from the data
execute 'cut tiles' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib pbfgraphbuilder -c \
          #{node[:valhalla][:conf_dir]}/#{node[:valhalla][:config]} #{extracts}"
  cwd     node[:valhalla][:base_dir]
  timeout node[:valhalla][:retile][:cut_tiles_timeout]
end

# TODO: add an execute for publishing the possible data issues to maproulette
# or some other such data correction facility
