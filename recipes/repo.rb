
case node['platform']
when 'ubuntu'
  include_recipe 'apt::default'
  # Ubuntu 14.04+ appears to have the right packages
  if Chef::VersionConstraint.new("< 12.04").include?(node['platform_version'])
    # May not be needed in modern ubuntu, debian.
    apt_repository 'mosquitto' do
      uri          'http://repo.mosquitto.org/debian'
      distribution node['lsb']['codename']
      components   ['main']
      key          'http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key'
    end
  end

when 'debian'
  include_recipe 'apt::default'
  # To install latest mosquitto, add sources.list for corresponding version
  src_list = "http://repo.mosquitto.org/debian"
  chk_sum = ""

  if !(/[^ ].*\/sid/  =~ node['platform_version']) && # sid
      Chef::VersionConstraint.new("< 8.0").include?(node['platform_version'])
    src_list = "#{src_list}/mosquitto-stable.list"
    chk_sum = "ca11a87df944f7ef24dc2ef3ab3b7cd7378fe977c7cba3a68386b3defa2dd217"
  else                          # jessie/sid
    src_list = "#{src_list}/mosquitto-jessie.list"
    chk_sum = "dfc7335938248a8c17dcbba197a40d374a82fecfc2bb74432766bf31bebe6c0d"
  end

  remote_file "/etc/apt/sources.list.d/mosquitto.list" do
    source src_list
    checksum chk_sum
    headers "Host" => URI.parse(source.first).host
  end

  remote_file "/tmp/mosquitto-repo.gpg.key" do
    source 'http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key'
    checksum '8c9f018c7cf4ac07e66886401cbdca76ec3a4077ab0a3ebe85b4a32e8c848558'
    headers "Host" => URI.parse(source.first).host
  end

  bash "apt-add-key-update" do
    command ['apt-key add /tmp/mosquitto-repo.gpg.key',
             'apt-get update']
    ignore_failure true
    only_if { apt_installed? }
  end

when "mac_os_x"
  # Supported by brew
when "redhat", "centos", "scientific", "fedora", "arch", "amazon"
  include_recipe 'yum::default'
  
  if Chef::VersionConstraint.new(">= 6.0").include?(node['platform_version']) &&
      Chef::VersionConstraint.new("< 7.0").include?(node['platform_version'])
    yum_repository 'mosquitto' do
      description 'Mosquitto Repository'
      baseurl     'http://download.opensuse.org/repositories/home:/oojah:/mqtt/CentOS_CentOS-6/'
      gpgkey      'http://download.opensuse.org/repositories/home:/oojah:/mqtt/CentOS_CentOS-6/repodata/repomd.xml.key'
      action :create
    end
  elsif Chef::VersionConstraint.new(">= 5.0").include?(node['platform_version'])
    yum_repository 'mosquitto' do
      description 'Mosquitto Repository'
      baseurl     'http://download.opensuse.org/repositories/home:/oojah:/mqtt/CentOS_CentOS-5/'
      gpgkey      'http://download.opensuse.org/repositories/home:/oojah:/mqtt/CentOS_CentOS-5/repodata/repomd.xml.key'
      action :create
    end
  else
    raise "Not yet supported, but pull requests welcome!"
  end
else
  raise "Not yet supported, but pull requests welcome!"
end
