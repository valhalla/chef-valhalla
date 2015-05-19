include_recipe 'mapzen_logstash::default'

logstashrc 'logstash_valhalla' do
  template_source   'logstash_valhalla.conf.erb'
  template_cookbook 'valhalla'
end
