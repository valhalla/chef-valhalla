# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: tile
#

# get the checksum for the data
remote_file "#{node[:valhalla][:tile_dir]}/#{node[:valhalla][:data][:file]}.md5" do
  action   :create
  backup   false
  source   "#{node[:valhalla][:data][:server]}/#{node[:valhalla][:data][:path]}/#{node[:valhalla][:data][:file]}.md5"
  mode     0644

  notifies :run, 'execute[download data]', :immediately
  notifies :run, 'ruby_block[verify md5]', :immediately
  notifies :run, 'execute[retile]', :delayed
end

# get the actual data
execute 'download data' do
  action  :nothing
  command "wget --quiet -O #{node[:valhalla][:tile_dir]}/#{node[:valhalla][:data][:file]} #{node[:valhalla][:data][:server]}/#{node[:valhalla][:data][:path]}/#{node[:valhalla][:data][:file]}"
  user    node[:valhalla][:user][:name]
end

# check the md5sum
ruby_block 'verify md5' do
  action :nothing
  block do
    require 'digest'
    planet_md5  = Digest::MD5.file("#{node[:valhalla][:tile_dir]}/#{node[:valhalla][:data][:file]}").hexdigest
    md5         = File.read("#{node[:valhalla][:tile_dir]}/#{node[:valhalla][:data][:file]}.md5").split(' ').first
    if planet_md5 != md5
      Chef::Log.info('Failure: the md5 of the data we downloaded does not appear to be correct. Aborting.')
      abort
    end
  end
end

# create new tiles and restart the server
execute 'retile' do
  action  :nothing

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
