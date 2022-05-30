# blackstack-nodes

**BlackStack Nodes** is a simple library to managing a computer remotely via SSH, and perform some common operations.

This library is used and extended by many others like: 
- [BlackStack Deployer](https://github.com/leandrosardi/blackstack-deployer)
- [Pampa](https://github.com/leandrosardi/pampa)
- [Simple Proxies Monitoring](https://github.com/leandrosardi/simple_proxies_deploying)
- [Simple Hosts Monitoring](https://github.com/leandrosardi/simple_host_monitoring)

## 1. Getting Started



## 2. Connecting a Node Using Private-Key Files

```ruby
# Example script of connecting to an AWS/EC2 instance using a key file; and running a command.

require_relative '../lib/blackstack-deployer'
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
```

## 3. Rebooting a Node and Waiting it to Get Back

```ruby
# Example script of connecting to an AWS/EC2 instance using a key file; requesting server reboot; and waiting for server is up again.

require 'simple_cloud_logging'
require_relative '../lib/blackstack-deployer'

logger = BlackStack::BaseLogger.new(nil)

n = BlackStack::Infrastructure::Node.new(
    {
        :net_remote_ip => '54.160.137.218',  
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
```

The log of this command will be something like this:

```bash
2022-05-30 15:37:26: Connecting to node... done
2022-05-30 15:37:28: Rebooting node...
2022-05-30 15:37:28:  > reboot... done
2022-05-30 15:37:30:  > wait 10 seconds... done
2022-05-30 15:37:40:  > connecting (try 1)... Net::SSH::ConnectionTimeout
2022-05-30 15:38:01:  > wait 10 seconds... done
2022-05-30 15:38:11:  > connecting (try 2)... No se puede establecer una conexi¾n ya que el equipo de destino deneg¾ expresamente dicha conexi¾n. - connect(2) for 81.28.96.103:22
2022-05-30 15:38:19:  > wait 10 seconds... done
2022-05-30 15:38:29:  > connecting (try 3)... done
```

## 3. Connecting a Node Using Password

```
# Example script of connecting to a server using ssh user and password; requesting server reboot; and waiting for server is up again.

require 'simple_cloud_logging'
require_relative '../lib/blackstack-deployer'

logger = BlackStack::BaseLogger.new(nil)

n = BlackStack::Infrastructure::Node.new(
    {
        :net_remote_ip => '81.28.96.103',  
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
```