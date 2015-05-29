# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: install
#

# clone software
execute 'clone tyr' do
  action    :run
  user      node[:valhalla][:user][:name]
  command   "rm -rf tyr && git clone --depth=1 --recurse-submodules --single-branch --branch=master \
            #{node[:valhalla][:github][:base]}/tyr.git"
  cwd       node[:valhalla][:src_dir]

  notifies  :run, 'execute[dependencies tyr]',  :immediately
  notifies  :run, 'execute[configure tyr]',     :immediately
  notifies  :run, 'execute[build tyr]',         :immediately
  notifies  :run, 'execute[install tyr]',       :immediately
end

# dependencies
execute 'dependencies tyr' do
  action  :nothing
  command "scripts/dependencies.sh #{node[:valhalla][:src_dir]}"
  cwd     "#{node[:valhalla][:src_dir]}/tyr"
end

# configure
execute 'configure tyr' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command './autogen.sh && ./configure CPPFLAGS="-DLOGGING_LEVEL_INFO" \
           --with-valhalla-midgard=/usr/local --with-valhalla-baldr=/usr/local \
           --with-valhalla-sif=/usr/local --with-valhalla-mjolnir=/usr/local \
           --with-valhalla-loki=/usr/local --with-valhalla-odin=/usr/local \
           --with-valhalla-thor=/usr/local --with-valhalla-tyr=/usr/local \
           CPPFLAGS=-DBOOST_SPIRIT_THREADSAFE'
  cwd     "#{node[:valhalla][:src_dir]}/tyr"
end

# build
execute 'build tyr' do
  action  :nothing
  user    node[:valhalla][:user][:name]
  command "make -j#{node[:cpu][:total]}"
  cwd     "#{node[:valhalla][:src_dir]}/tyr"
end

# install
execute 'install tyr' do
  action  :nothing
  command "make -j#{node[:cpu][:total]} install"
  cwd     "#{node[:valhalla][:src_dir]}/tyr"
end
