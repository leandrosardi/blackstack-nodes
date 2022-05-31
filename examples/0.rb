# Example script of connecting to an AWS/EC2 instance using a key file; and running a command.

require 'blackstack-nodes'

n = BlackStack::Infrastructure::Node.new(
    :net_remote_ip => '54.160.137.218',  
    :ssh_username => 'ubuntu',
    :ssh_port => 22,
    :ssh_private_key_file => './plank.pem',
)
# => BlackStack::Infrastructure::RemoteNode

n.connect
# => n.ssh

puts n.exec('hostname')
# => 'ip-172-31-21-6'

n.disconnect
# => nil

