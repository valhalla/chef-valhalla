# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: get_osm_data
#

# for each extract
node[:valhalla][:extracts].each do |url|
  # for the sake of brevity
  file = url.split('/').last

  # get the checksum for the data
  remote_file "#{node[:valhalla][:extracts_dir]}/#{file}.md5" do
    action   :create
    backup   false
    source   "#{url}.md5"
    mode     0644
    only_if  { node[:valhalla][:with_updates] == false || File.exist?("#{node[:valhalla][:extracts_dir]}/#{file}") == false }

    notifies :run, "execute[download #{url}]", :immediately
    notifies :run, "ruby_block[verify #{file}]", :immediately
    notifies :run, "execute[minutely_initialize #{file}]", :immediately
  end

  # get the actual data
  execute "download #{url}" do
    action  :nothing
    command "wget --quiet -O #{node[:valhalla][:extracts_dir]}/#{file} #{url}"
    user    node[:valhalla][:user][:name]
    timeout 10_800
  end

  # check the md5sum
  ruby_block "verify #{file}" do
    action :nothing
    block do
      require 'digest'
      file_md5  = Digest::MD5.file("#{node[:valhalla][:extracts_dir]}/#{file}").hexdigest
      md5         = File.read("#{node[:valhalla][:extracts_dir]}/#{file}.md5").split(' ').first
      if file_md5 != md5
        Chef::Log.info('Failure: the md5 of the data we downloaded does not appear to be correct. Aborting.')
        abort
      end
    end
  end

  # initialize the minutely updates
  execute "minutely_initialize #{file}" do
    action  :nothing
    command "#{node[:valhalla][:conf_dir]}/minutely_update.sh initialize #{node[:valhalla][:extracts_dir]} #{file}"
    user    node[:valhalla][:user][:name]
  end
end
