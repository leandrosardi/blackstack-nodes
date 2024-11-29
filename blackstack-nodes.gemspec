Gem::Specification.new do |s|
  s.name        = 'blackstack-nodes'
  s.version     = '1.2.17'
  s.date        = '2024-11-29'
  s.summary     = "BlackStack Nodes is a simple library to managing a computer remotely via SSH, and perform some common operations."
  s.description = "BlackStack Nodes is a simple library to managing a computer remotely via SSH, and perform some common operations.
This library is used and extended by many others like: 
- [BlackStack Deployer](https://github.com/leandrosardi/blackstack-deployer)
- [Pampa](https://github.com/leandrosardi/pampa)
- [Simple Proxies Monitoring](https://github.com/leandrosardi/simple_proxies_deploying)
- [Simple Hosts Monitoring](https://github.com/leandrosardi/simple_host_monitoring)  
"
  s.authors     = ["Leandro Daniel Sardi"]
  s.email       = 'leandro.sardi@expandedventure.com'
  s.files       = [
    "lib/blackstack-nodes.rb",
  ]
  s.homepage    = 'https://github.com/leandrosardi/blackstack-nodes'
  s.license     = 'MIT'
  s.add_runtime_dependency 'net-ssh', '~> 6.1.0'
  s.add_runtime_dependency 'simple_cloud_logging', '~> 1.2.2'
end