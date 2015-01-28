# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: install
#

include_recipe 'valhalla::retile'

# for each repository
node[:valhalla][:github][:repos].each do |repo|
  # clone it
  git "#{node[:valhalla][:src_dir]}/#{repo}" do
    action            :sync
    user              node[:valhalla][:user][:name]
    repo              "#{node[:valhalla][:github][:base]}/#{repo}.git"
    revision          node[:valhalla][:github][:revision]
    enable_submodules true
    depth             1

    notifies :run, "execute[configure #{repo}]", :immediately
    notifies :run, "execute[build #{repo}]", :immediately
    notifies :run, "execute[install #{repo}]", :immediately
    notifies :run, 'execute[retile]', :delayed
  end

  # configure
  execute "configure #{repo}" do
    action  :nothing
    user    node[:valhalla][:user][:name]
    command './autogen.sh && ./configure CPPFLAGS="-DLOGGING_LEVEL_INFO" \
             --with-valhalla-midgard=/usr/local --with-valhalla-baldr=/usr/local \
             --with-valhalla-mjolnir=/usr/local --with-valhalla-loki=/usr/local \
             --with-valhalla-odin=/usr/local --with-valhalla-thor=/usr/local \
             --with-valhalla-tyr=/usr/local'
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
