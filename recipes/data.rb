# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: data
#

include_recipe 'retile'

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
