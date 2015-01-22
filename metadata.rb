# -*- coding: UTF-8 -*-

name             'valhalla'
maintainer       'mapzen'
maintainer_email 'kevin@mapzen.com'
license          'MIT'
description      'Installs/Configures valhalla'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'

recipe 'valhalla', 'Installs valhalla'

%w(
  apt
  git
  user
).each do |dep|
  depends dep
end

supports 'ubuntu', '>= 12.04'
