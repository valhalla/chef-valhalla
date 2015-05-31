# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: fresh_tiles
#

execute 'pull_tiles' do
  action  :run
  user    node[:valhalla][:user][:name]
  cwd     node[:valhalla][:base_dir]
  command <<-EOH
    #{node[:valhalla][:conf_dir]}/pull_tiles.py > latest_tiles.txt
  EOH

  notifies :run, 'execute[extract tiles]', :immediately
  notifies :run, 'execute[stop workers]', :immediately
  notifies :run, 'execute[move tiles]', :immediately
  notifies :run, 'execute[start workers]', :immediately
end

execute 'extract tiles' do
  action  :run
  user    node[:valhalla][:user][:name]
  cwd     node[:valhalla][:base_dir]
  command <<-EOH
    rm -rf tmp_tiles &&
    mkdir tmp_tiles &&
    curl $(cat latest_tiles.txt) | tar xzp -C tmp_tiles
  EOH
end

execute 'stop workers' do
  action      :run
  command     <<-EOH
    count=$((#{node[:valhalla][:workers][:count]} - 1))
    for i in loki thor odin tyr; do
      for j in {0..${count}}; do
        service stop workerd-${i}-${j}
      done
    done
  EOH
  cwd node[:valhalla][:base_dir]
end

execute 'move tiles' do
  action  :run
  user    node[:valhalla][:user][:name]
  command "rm -rf #{node[:valhalla][:tile_dir]}; mv tmp_tiles #{node[:valhalla][:tile_dir]}"
  cwd     node[:valhalla][:base_dir]
end

execute 'start workers' do
  action  :run
  cwd     node[:valhalla][:base_dir]
  command <<-EOH
    count=$((#{node[:valhalla][:workers][:count]} - 1))
    for i in loki thor odin tyr; do
      for j in {0..${count}}; do
        service start workerd-${i}-${j}
      done
    done
  EOH
end
