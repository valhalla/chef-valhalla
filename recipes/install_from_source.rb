# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: install_from_source
#

# remove previous software
execute package_remove do
  action :run
  command '(apt-get purge -y libvalhalla* valhalla* || true) && rm -rf /usr/local/lib/libvalhalla* /usr/local/include/valhalla /usr/local/bin/valhalla*'
end

%w(midgard baldr sif meili skadi mjolnir loki odin thor tyr tools).each do |layer|
  # clone software
  execute "clone #{layer}" do
    action    :run
    command   "rm -rf #{layer} && git clone --depth=1 --recurse-submodules --single-branch \
              --branch=#{node[:valhalla][:revision]} \
              #{node[:valhalla][:github][:base]}/#{layer}.git"
    cwd       node[:valhalla][:src_dir]

    notifies  :run, "execute[install #{layer}]",       :immediately
  end

  # install
  execute "install #{layer}" do
    action  :nothing
    command 'scripts/install.sh'
    cwd     "#{node[:valhalla][:src_dir]}/#{layer}"
  end
end

# restart the services if they are present
include_recipe 'runit::default'
stop_service do
end
start_service do
end
