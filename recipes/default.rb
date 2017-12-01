#
# Cookbook:: DGallery
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
##############################################################
conf = data_bag_item('conf', 'conf')
#first install epel repository
package "epel-release" do
  action :install
end


rpm_package "rpmfusion-free-release-7.noarch.rpm" do
  source "https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm"
  action :install
end


rpm_package "rpmfusion-nonfree-release-7.noarch.rpm" do
  source "https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm"
  action :install
end


conf["packages"].each  do |pkg|
  package pkg do
    action :install
  end
end

service "firewalld" do
  action :disable
  action :stop
end

#selinux_state "SELinux disabling" do
#  action :disabled
#end

####################configure and install DGallery
[conf['data'][0]["DGallery_dir"] , conf['data'][0]["albums_dir"]].each do |new_dir|
  directory new_dir do
   owner conf['data'][0]["run_user"]
   group conf['data'][0]["run_group"]
   mode '0755'
   action :create
  end
end

#get newest app from github
git conf['data'][0]["DGallery_dir"] do
  repository conf['data'][0]["github_src"]
  revision 'master'
  action :sync
end

#install python requierments
execute 'installing Python libraries' do
  command "pip install -r #{conf['data'][0]["DGallery_dir"]}/DymbolGallery/requirements.txt"
end
