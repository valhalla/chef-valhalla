# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: install
#

%w(mjolnir tools).each do |layer|
  # clone software
  execute "clone #{layer}" do
    action    :run
    command   "rm -rf #{layer} && git clone --depth=1 --recurse-submodules --single-branch --branch=master \
              #{node[:valhalla][:github][:base]}/#{layer}.git"
    cwd       node[:valhalla][:src_dir]

    notifies  :run, "execute[dependencies #{layer}]",  :immediately
    notifies  :run, "execute[configure #{layer}]",     :immediately
    notifies  :run, "execute[build #{layer}]",         :immediately
    notifies  :run, "execute[install #{layer}]",       :immediately
  end

  # dependencies
  execute "dependencies #{layer}" do
    action  :nothing
    command "scripts/dependencies.sh #{node[:valhalla][:src_dir]}"
    cwd     "#{node[:valhalla][:src_dir]}/#{layer}"
  end

  # configure
  execute "configure #{layer}" do
    action  :nothing
    command 'scripts/install.sh'
    cwd     "#{node[:valhalla][:src_dir]}/#{layer}"
  end

  # build
  execute "build #{layer}" do
    action  :nothing
    command "make -j#{node[:cpu][:total]}"
    cwd     "#{node[:valhalla][:src_dir]}/#{layer}"
  end

  # install
  execute "install #{layer}" do
    action  :nothing
    command "make -j#{node[:cpu][:total]} install"
    cwd     "#{node[:valhalla][:src_dir]}/#{layer}"
  end
end

# restart the services if they are present
include_recipe 'runit::default'
stop_service do
end
start_service do
end
