# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: data
#

include_recipe 'valhalla::retile'

# for each extract
node[:valhalla][:extract].each do |url|
  # for the sake of brevity
  file = url.split('/').last

  # get the checksum for the data
  remote_file "#{node[:valhalla][:tile_dir]}/#{file}.md5" do
    action   :create
    backup   false
    source   "#{url}.md5"
    mode     0644

    notifies :run, "execute[download #{url}]", :immediately
    notifies :run, "ruby_block[verify #{file}]", :immediately
    notifies :run, 'execute[retile]', :delayed
  end

  # get the actual data
  execute "download #{url}" do
    action  :nothing
    command "wget --quiet -O #{node[:valhalla][:tile_dir]}/#{file} #{url}"
    user    node[:valhalla][:user][:name]
  end

  # check the md5sum
  ruby_block "verify #{file}" do
    action :nothing
    block do
      require 'digest'
      file_md5  = Digest::MD5.file("#{node[:valhalla][:tile_dir]}/#{file}").hexdigest
      md5         = File.read("#{node[:valhalla][:tile_dir]}/#{file}.md5").split(' ').first
      if file_md5 != md5
        Chef::Log.info('Failure: the md5 of the data we downloaded does not appear to be correct. Aborting.')
        abort
      end
    end
  end
end
