# -*- coding: UTF-8 -*-

name             'valhalla'
maintainer       'valhalla'
maintainer_email 'valhalla@mapzen.com'
license          'MIT'
description      'Installs/Configures valhalla'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.6'

recipe 'valhalla', 'Installs valhalla'

%w(
  apt
  user
  runit
).each do |dep|
  depends dep
end

supports 'ubuntu', '>= 12.04'
