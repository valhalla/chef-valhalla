# -*- coding: UTF-8 -*-
#
# Cookbook Name:: valhalla
# Attributes:: default
#

# where to do some install work
default[:valhalla][:basedir]            = '/opt/valhalla'

# the repos
default[:valhalla][:github][:base]      = 'https://github.com/valhalla/'
default[:valhalla][:github][:repos]     = %w(midgard baldr mjolnir loki odin thor tyr)
default[:valhalla][:github][:revision]  = 'master'

# valhalla user to create
default[:valhalla][:user][:name]        = 'valhalla'
default[:valhalla][:user][:home]        = '/home/valhalla'
