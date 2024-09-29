# Example script of connecting to an AWS/EC2 instance using a key file; requesting server reboot; and waiting for server is up again.

require 'simple_cloud_logging'
require 'blackstack-nodes'

logger = BlackStack::BaseLogger.new(nil)

n = BlackStack::Infrastructure::Node.new(
    {
        :ip => '54.160.137.218',  
        :ssh_username => 'ubuntu',
        :ssh_port => 22,
        :ssh_private_key_file => './plank.pem',
    }, 
    logger
)
# => BlackStack::Infrastructure::RemoteNode

logger.logs 'Connecting to node... '
n.connect
# => n.ssh
logger.done

logger.logs 'Rebooting node... '
puts n.reboot
logger.done

logger.logs 'Disconnecting from node... '
n.disconnect
# => nil
logger.done
