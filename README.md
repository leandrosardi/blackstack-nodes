# blackstack-nodes

**BlackStack Nodes** is a simple library to managing a computer remotely via SSH, and perform some common operations.

This library is used and extended by many others like: 
- [BlackStack Deployer](https://github.com/leandrosardi/blackstack-deployer)
- [Pampa](https://github.com/leandrosardi/pampa)
- [Simple Proxies Monitoring](https://github.com/leandrosardi/simple_proxies_deploying)
- [Simple Hosts Monitoring](https://github.com/leandrosardi/simple_host_monitoring)

**Outline**

1. [Installation](#1-installation)
2. [Getting Started](#2-getting-started)
3. [Using Private-Keys](#3-using-private-keys)
4. [Rebooting Nodes](#4-rebooting-nodes)
5. [Logging](#5-logging)
6. [Usage](#6-monitoring)

## 1. Installation

Install the gem.

```bash
gem install blackstack-nodes
```

## 2. Getting Started

```ruby
require 'simple_cloud_logging'

n = BlackStack::Infrastructure::Node.new({
    :net_remote_ip => '81.28.96.103',  
    :ssh_username => 'root',
    :ssh_port => 22,
    :ssh_password => '****',
})
# => BlackStack::Infrastructure::Node

n.connect
# => n.ssh

puts n.exec('hostname')
# => 'dev1'

n.disconnect
# => nil
```

## 3. Using Private-Keys

```ruby
require 'simple_cloud_logging'

n = BlackStack::Infrastructure::Node.new({
    :net_remote_ip => '54.160.137.218',  
    :ssh_username => 'ubuntu',
    :ssh_port => 22,
    :ssh_private_key_file => './plank.pem',
})
# => BlackStack::Infrastructure::Node

n.connect
# => n.ssh

puts n.exec('hostname')
# => 'dev1'

n.disconnect
# => nil
```

## 4. Rebooting Nodes

Use the `reboot` method for not only reboot the node, but wait for it to get back too.

```ruby
require 'simple_cloud_logging'

n = BlackStack::Infrastructure::Node.new({
    :net_remote_ip => '54.160.137.218',  
    :ssh_username => 'ubuntu',
    :ssh_port => 22,
    :ssh_private_key_file => './plank.pem',
})
# => BlackStack::Infrastructure::RemoteNode

n.connect
# => n.ssh

puts n.reboot # your code will remiains here until the node is get again.
# => nil

n.disconnect
# => nil
```

## 5. Logging

You can integrate **blackstack-nodes** our other **[simple_cloud_logging](https://github.com/leandrosardi/simple_cloud_logging)** gem.

**Example:**

```ruby
require 'simple_cloud_logging'

logger = BlackStack::LocalLogger.new('./example.log')

n = BlackStack::Infrastructure::Node.new({
    :net_remote_ip => '54.160.137.218',  
    :ssh_username => 'ubuntu',
    :ssh_port => 22,
    :ssh_private_key_file => './plank.pem',
}, logger)
# => BlackStack::Infrastructure::RemoteNode

n.connect
# => n.ssh

puts n.reboot # your code will remiains here until the node is get again.
# => nil

n.disconnect
# => nil
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

## 6. Monitoring

You can remotely monitor the usage of memory, CPU and disk space of a node.

```ruby
require 'simple_cloud_logging'

n = BlackStack::Infrastructure::Node.new({
    :net_remote_ip => '54.160.137.218',  
    :ssh_username => 'ubuntu',
    :ssh_port => 22,
    :ssh_private_key_file => './plank.pem',
})
# => BlackStack::Infrastructure::RemoteNode

n.connect
# => n.ssh

puts n.usage
# => { :gb_total_memory => ..., :gb_free_memory => ..., ... }

n.disconnect
# => nil
```

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the last [ruby gem](https://rubygems.org/gems/simple_command_line_parser). 

## Authors

* **Leandro Daniel Sardi** - *Initial work* - [LeandroSardi](https://github.com/leandrosardi)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Further Work

Nothing yet.