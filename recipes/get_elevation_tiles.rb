# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: get_elevation_tiles
#

# stop everything from running
execute 'stop service' do
  action      :run
  command     <<-EOH
    service prime-httpd stop
    count=$((#{node[:valhalla][:workers][:count]} - 1))
    service proxyd-skadi stop
    for j in $(seq 0 ${count}); do
      service workerd-skadi-${j} stop
    done
  EOH
  cwd node[:valhalla][:base_dir]

  notifies :run, 'execute[sync tiles]', :immediately
  notifies :run, 'execute[inflate tiles]', :immediately
end

# get them from s3
execute 'sync tiles' do
  action  :run
  user    node[:valhalla][:user][:name]
  cwd     node[:valhalla][:base_dir]
  command <<-EOH
    for x in {-180..179}; do
      for y in {-90..89}; do
        file=\$(python -c "print '%s%02d%s%03d.hgt.gz' % ('S' if \$y < 0 else 'N', abs(\$y), 'W' if \$x < 0 else 'E', abs(\$x))")
        dir=\$(echo \$file | sed "s/^\\([NS][0-9]\\{2\\}\\).*/\1/g")
        echo "--retry 3 --retry-delay 0 --max-time 100 -s --create-dirs -o #{node[:valhalla][:elevation_dir]}/\$dir/\$file #{node[:valhalla][:elevation_url]}/\$dir/\$file"
      done
    done | parallel -C ' ' -P \$(nproc) "echo {}"
  EOH
  timeout 8_000
end

# inflate the tiles
execute 'inflate tiles' do
  action :run
  user    node[:valhalla][:user][:name]
  cwd     node[:valhalla][:elevation_dir]
  command 'find . | grep -F .gz | xargs -P $(nproc) gunzip'
  timeout 8_000
end

# turn everything back on
include_recipe 'valhalla::_restart'
