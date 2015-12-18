#
# Cookbook Name:: cookbook-setlayout
# Recipe:: default
#
# Copyright 2015, byplayer
#
# All rights reserved - Do Not Redistribute
#
packages = case node['platform_family']
           when 'rhel'
             %w(libevent-devel ncurses-devel gcc make)
           else
             %w(libevent-dev libncurses5-dev gcc make)
           end

packages.each do |name|
  package name
end

source_url = node['setlayout']['source_url'] % { :version => node['setlayout']['version'] }
file_name = 'setlayout-' + source_url.split('/').last.gsub('v', '')
remote_file "#{Chef::Config['file_cache_path']}/#{file_name}" do
  source source_url
  checksum node['setlayout']['checksum']
  notifies :run, 'bash[install_setlayout]', :immediately
end

bash 'install_setlayout' do
  user 'root'
  cwd Chef::Config['file_cache_path']
  code <<-EOH
      tar -zxf #{file_name}
      cd #{file_name.gsub(/\.tar\.gz/, '')}
      ./configure #{node['setlayout']['configure_options'].join(' ')}
      make
      make install
    EOH
  action :nothing
end
