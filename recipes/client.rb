client_packages = %w{mosquitto-clients libmosquitto1 libmosquitto-devel libmosquittopp1 libmosquittopp-devel python-mosquitto}

case node['platform']
when 'ubuntu'
  client_packages = %w{mosquitto-clients libmosquitto0 libmosquitto0-dev libmosquittopp0 libmosquittopp0-dev python-mosquitto}
when 'debian'
  if (/[^ ].*\/sid/  =~ node['platform_version']) # sid
    client_packages = %w{mosquitto-clients libmosquitto1 libmosquitto-dev libmosquittopp1 libmosquittopp-dev python-mosquitto}
  else
    client_packages = %w{mosquitto-clients libmosquitto0 libmosquitto0-dev libmosquittopp0 libmosquittopp0-dev python-mosquitto}
  end
when "redhat", "centos", "scientific", "fedora", "arch", "amazon"
  client_packages = %w{mosquitto-clients libmosquitto1 libmosquitto-devel libmosquittopp1 libmosquittopp-devel python-mosquitto}
end

client_packages.each do |pkg|
  package pkg
end
