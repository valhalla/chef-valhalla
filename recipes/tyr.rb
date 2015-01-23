# -*- ctyrg: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: tyr
#

# clone the repository
deploy "#{node[:valhalla][:basedir]}/tyr" do
  user node[:valhalla][:user][:name]
  repo node[:valhalla][:tyr][:repo]
  revision node[:valhalla][:tyr][:revision]
  enable_submodules true
  shallow_clone true
  symlink_before_migrate.clear

  notifies :run, 'execute[submodules]'
  notifies :run, 'execute[configure tyr]'
  notifies :run, 'execute[install tyr]'
end

# fetch the submodules
execute 'submodules' do
  action :nothing
  command 'git submodule update --init --recursive'
  cwd "#{node[:valhalla][:basedir]}/tyr/current"
end

# configure valhalla::tyr
execute 'configure tyr' do
  action :nothing
  command './autogen.sh && ./configure CPPFLAGS="-DLOGGING_LEVEL_INFO" --with-valhalla-tyr=/usr/local --with-valhalla-baldr=/usr/local --with-valhalla-loki=/usr/local --with-valhalla-mjolnir=/usr/local --with-valhalla-odin=/usr/local --with-valhalla-thor=/usr/local'
  cwd "#{node[:valhalla][:basedir]}/tyr/current"
end

# install valhalla::tyr
execute 'install tyr' do
  action :nothing
  command "make -j#{node[:cpu][:total]} install"
  cwd "#{node[:valhalla][:basedir]}/tyr/current"
end
