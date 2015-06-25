# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: get_tiles
#

execute 'stop service' do
  action      :run
  command     <<-EOH
    service prime-httpd stop
    count=$((#{node[:valhalla][:workers][:count]} - 1))
    for i in loki thor odin tyr; do
      service proxyd-${i} stop
      for j in $(seq 0 ${count}); do
        service workerd-${i}-${j} stop
      done
    done
  EOH
  cwd node[:valhalla][:base_dir]

  notifies :run, 'execute[pull tiles]', :immediately
  notifies :run, 'execute[extract tiles]', :immediately
  notifies :run, 'execute[move tiles]', :immediately
  notifies :run, 'execute[start service]', :immediately
  notifies :run, 'execute[test service]', :immediately
end

execute 'pull tiles' do
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

execute 'move tiles' do
  action  :run
  user    node[:valhalla][:user][:name]
  command "rm -rf #{node[:valhalla][:tile_dir]}; mv tmp_tiles #{node[:valhalla][:tile_dir]}"
  cwd     node[:valhalla][:base_dir]
end

execute 'start service' do
  action  :run
  cwd     node[:valhalla][:base_dir]
  command <<-EOH
    service prime-httpd start
    count=$((#{node[:valhalla][:workers][:count]} - 1))
    for i in loki thor odin tyr; do
      service proxyd-${i} start
      for j in $(seq 0 ${count}); do
        service workerd-${i}-${j} start
      done
    done
  EOH
end

execute 'test service' do
  action  :run
  user    node[:valhalla][:user][:name]
  command 'curl localhost:8080/route --fail --data \'{"locations":[{"lat":40.402918,"lon":-76.535017},{"lat":40.403654,"lon": -76.529846}],"costing":"auto"}\''
  cwd     node[:valhalla][:base_dir]
end
