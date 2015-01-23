# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Attributes:: default
#

# where to do some install work
default[:valhalla][:basedir]            = '/opt/valhalla'

# the repos
default[:valhalla][:midgard][:repo]     = 'https://github.com/valhalla/midgard.git'
default[:valhalla][:midgard][:revision] = 'master'

# valhalla user to create
default[:valhalla][:user][:name]        = 'valhalla'
default[:valhalla][:user][:home]        = '/home/valhalla'
