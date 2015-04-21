# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: minutely_update
#

# for each extract
node[:valhalla][:extracts].each do |url|
  # for the sake of brevity
  file = url.split('/').last

  execute 'minutely_update' do
    action  :nothing
    command 'echo "Updating latest pbf"'

    notifies :run, "execute[update #{file}]", :immediately
  end

  # get the actual data and update each pbf
  execute "update #{file}" do
    action  :nothing
    command "#{node[:valhalla][:src_dir]}/mjolnir/scripts/minutely_update.sh update #{node[:valhalla][:extracts_dir]} #{file}"
    user    node[:valhalla][:user][:name]
  end
end

