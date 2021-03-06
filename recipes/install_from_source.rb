# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Recipe:: install_from_source
#

# remove previous software
execute 'package remove' do
  action :run
  command '(apt-get purge -y libvalhalla* valhalla* || true) && rm -rf /usr/local/lib/libvalhalla* /usr/local/include/valhalla /usr/local/bin/valhalla*'
end

# clone software
execute 'clone libvalhalla' do
  action    :run
  command   "rm -rf valhalla && git clone --depth=1 --recurse-submodules --single-branch \
            --branch=#{node[:valhalla][:github][:revision]} \
            #{node[:valhalla][:github][:base]}/valhalla.git"
  cwd       node[:valhalla][:src_dir]

  notifies  :run, 'execute[install libvalhalla]',       :immediately
end

# install
execute 'install libvalhalla' do
  action  :nothing
  command './autogen.sh && ./configure && make -j$(nproc) && make install'
  cwd     "#{node[:valhalla][:src_dir]}/valhalla"
end

# restart the services if they are present
include_recipe 'runit::default'
stop_service do
end
start_service do
end
