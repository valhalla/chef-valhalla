# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: data
#

include_recipe 'valhalla::freshtiles'

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

    notifies :run, "execute[download #{url}]", :immediately
    notifies :run, "ruby_block[verify #{file}]", :immediately
    notifies :run, "execute[minutely_initialize #{file}]", :immediately
    notifies :run, 'execute[freshtiles]', :delayed
  end

  # get the actual data
  execute "download #{url}" do
    action  :nothing
    command "wget --quiet -O #{node[:valhalla][:extracts_dir]}/#{file} #{url}"
    user    node[:valhalla][:user][:name]
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
    command "#{node[:valhalla][:src_dir]}/mjolnir/scripts/minutely_update.sh initialize #{node[:valhalla][:extracts_dir]} #{file}"
    user    node[:valhalla][:user][:name]
  end

end
