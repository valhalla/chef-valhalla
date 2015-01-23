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
default[:valhalla][:baldr][:repo]       = 'https://github.com/valhalla/baldr.git'
default[:valhalla][:baldr][:revision]   = 'master'
default[:valhalla][:loki][:repo]        = 'https://github.com/valhalla/loki.git'
default[:valhalla][:loki][:revision]    = 'master'
default[:valhalla][:mjolnir][:repo]     = 'https://github.com/valhalla/mjolnir.git'
default[:valhalla][:mjolnir][:revision] = 'master'
default[:valhalla][:thor][:repo]        = 'https://github.com/valhalla/thor.git'
default[:valhalla][:thor][:revision]    = 'master'
default[:valhalla][:odin][:repo]        = 'https://github.com/valhalla/odin.git'
default[:valhalla][:odin][:revision]    = 'master'
default[:valhalla][:tyr][:repo]         = 'https://github.com/valhalla/tyr.git'
default[:valhalla][:tyr][:revision]     = 'master'
default[:valhalla][:demos][:repo]       = 'https://github.com/valhalla/demos.git'
default[:valhalla][:demos][:revision]   = 'master'

# valhalla user to create
default[:valhalla][:user][:name]        = 'valhalla'
default[:valhalla][:user][:home]        = '/home/valhalla'
