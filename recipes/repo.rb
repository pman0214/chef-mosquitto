
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

  # Debian 7.0 or lower need the repo (wheezy)
  if Chef::VersionConstraint.new("<= 7.0").include?(node['platform_version'])
    # May not be needed in modern ubuntu, debian.
    apt_repository 'mosquitto' do
      uri          'http://repo.mosquitto.org/debian'
      distribution node['lsb']['codename']
      components   ['main']
      key          'http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key'
    end
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
