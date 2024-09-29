# Example script of connecting to a server using ssh user and password; requesting server reboot; and waiting for server is up again.

require 'simple_cloud_logging'
require 'blackstack-nodes'

logger = BlackStack::BaseLogger.new(nil)

n = BlackStack::Infrastructure::Node.new(
    {
        :ip => '81.28.96.103',  
        :ssh_username => 'root',
        :ssh_port => 22,
        :ssh_password => '****',
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
