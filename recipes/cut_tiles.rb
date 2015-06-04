# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: cut_tiles
#

# cut tiles as a one-off
execute 'cut tiles' do
  user    node[:valhalla][:user][:name]
  cwd     node[:valhalla][:base_dir]
  command <<-EOH
    #{node[:valhalla][:conf_dir]}/cut_tiles.sh >>#{node[:valhalla][:log_dir]}/cut_tiles.log 2>&1
  EOH
  only_if { node[:valhalla][:with_updates] == false }
end

# or install crontab to cut tiles all the time
cron 'cut tiles' do
  user    node[:valhalla][:user][:name]
  minute  '*/5'
  command <<-EOH
    cd #{node[:valhalla][:base_dir]} && #{node[:valhalla][:conf_dir]}/cut_tiles.sh >> #{node[:valhalla][:log_dir]}/cut_tiles.log 2>&1
  EOH
  only_if { node[:valhalla][:with_updates] == true }
end

# make sure to keep the data up to date if we are constantly cutting tiles
node[:valhalla][:extracts].each do |file|
  cron "apply changeset #{file}" do
    user    node[:valhalla][:user][:name]
    minute  '*/5'
    command <<-EOH
      cd #{node[:valhalla][:base_dir]} && #{node[:valhalla][:conf_dir]}/minutely_update.sh update #{node[:valhalla][:extracts_dir]} #{file} >> #{node[:valhalla][:log_dir]}/minutely_update_#{file}.log 2>&1
    EOH
    only_if { node[:valhalla][:with_updates] == true }
  end
end
