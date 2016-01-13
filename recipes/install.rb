# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: install
#

%w(tools).each do |layer|
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
    command './autogen.sh && ./configure CPPFLAGS="-DLOGGING_LEVEL_INFO" \
             --with-valhalla-midgard=/usr/local --with-valhalla-baldr=/usr/local \
             --with-valhalla-skadi=/usr/local --with-valhalla-sif=/usr/local \
             --with-valhalla-mjolnir=/usr/local --with-valhalla-loki=/usr/local \
             --with-valhalla-odin=/usr/local --with-valhalla-thor=/usr/local \
             --with-valhalla-tyr=/usr/local CPPFLAGS=-DBOOST_SPIRIT_THREADSAFE'
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
