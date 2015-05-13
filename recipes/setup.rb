# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: setup
#

# make the valhalla user
user_account node[:valhalla][:user][:name] do
  manage_home   true
  create_group  true
  ssh_keygen    false
  home          node[:valhalla][:user][:home]
  not_if        { node[:valhalla][:user][:name] == 'root' }
end

# make a few places to work in
[
  node[:valhalla][:base_dir],
  node[:valhalla][:tile_dir],
  node[:valhalla][:mjolnir_tile_dir],
  node[:valhalla][:log_dir],
  node[:valhalla][:conf_dir],
  node[:valhalla][:src_dir],
  node[:valhalla][:extracts_dir]
].each do |dir|
  directory dir do
    action    :create
    recursive true
    mode      0755
    owner     node[:valhalla][:user][:name]
  end
end

# move the config file into place
template "#{node[:valhalla][:conf_dir]}/#{node[:valhalla][:config]}" do
  source "#{node[:valhalla][:config]}.erb"
  mode   0644
  owner  node[:valhalla][:user][:name]
end

# we only need tyr it has everything
%w(tyr).each do |repo|
  # clone software
  git "#{node[:valhalla][:src_dir]}/#{repo}" do
    action            :sync
    user              node[:valhalla][:user][:name]
    repo              "#{node[:valhalla][:github][:base]}/#{repo}.git"
    revision          node[:valhalla][:github][:revision]
    enable_submodules true
    depth             1
  
    notifies :run, "execute[dependencies #{repo}]", :immediately
    notifies :run, "execute[configure #{repo}]", :immediately
    notifies :run, "execute[build #{repo}]", :immediately
    notifies :run, "execute[install #{repo}]", :immediately
  end
  
  # dependencies
  execute "dependencies #{repo}" do
    action  :nothing
    command 'scripts/dependencies.sh'
    cwd     "#{node[:valhalla][:src_dir]}/#{repo}"
  end
  
  # configure
  execute "configure #{repo}" do
    action  :nothing
    user    node[:valhalla][:user][:name]
    command './autogen.sh && ./configure CPPFLAGS="-DLOGGING_LEVEL_INFO" \
             --with-valhalla-midgard=/usr/local --with-valhalla-baldr=/usr/local \
             --with-valhalla-sif=/usr/local --with-valhalla-mjolnir=/usr/local \
             --with-valhalla-loki=/usr/local --with-valhalla-odin=/usr/local \
             --with-valhalla-thor=/usr/local --with-valhalla-tyr=/usr/local \
             CPPFLAGS=-DBOOST_SPIRIT_THREADSAFE'
    cwd     "#{node[:valhalla][:src_dir]}/#{repo}"
  end
  
  # build
  execute "build #{repo}" do
    action  :nothing
    user    node[:valhalla][:user][:name]
    command "make -j#{node[:cpu][:total]}"
    cwd     "#{node[:valhalla][:src_dir]}/#{repo}"
  end
  
  # install
  execute "install #{repo}" do
    action  :nothing
    command "make -j#{node[:cpu][:total]} install"
    cwd     "#{node[:valhalla][:src_dir]}/#{repo}"
  end
end
