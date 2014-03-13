#
# Cookbook Name:: my-jboss-app
# Recipe:: default
#
# Copyright 2014, Vladimir Mironov, EPAM Systems
#
# All rights reserved - Do Not Redistribute
#
home = node['my_jboss_app']['home']
user = node['my_jboss_app']['user']
group = node['my_jboss_app']['group']

directory "#{home}/#{node['my_jboss_app']['app']}" do
    owner user
    group group
    mode 00755
    recursive true
    action :create
end

directory "#{Chef::Config['file_cache_path']}" do
    mode 00755
    recursive true
    action :create
end

# Download the archive
# http://www.cumulogic.com/download/Apps/testweb.zip
remote_file "#{Chef::Config['file_cache_path']}/#{node['my_jboss_app']['app']}.zip" do
  owner user
  group group
  mode 00644
  action :create_if_missing
  source "#{node['my_jboss_app']['mirror']}/#{node['my_jboss_app']['app']}.zip"
end

package 'unzip' do
    action [:install]
end

bash 'extract-archive' do
    user user
    group group
    cwd home
code <<-EOH
rm -rf *
unzip "#{Chef::Config['file_cache_path']}/#{node['my_jboss_app']['app']}.zip"
EOH
end

# restart jboss
service 'jboss' do
  action [ :stop ]
end

service 'jboss' do
  action [ :start ]
end

