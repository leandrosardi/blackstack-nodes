require 'net/ssh'
require 'shellwords'
require 'simple_cloud_logging'
# 
module BlackStack
  # 
  module Infrastructure
    # this module has attributes an methods used by both classes Node and Node.
    module NodeModule
      # :name is this is just a descriptive name for the node. It is not the host name, nor the domain, nor any ip. 
      attr_accessor :name, :net_remote_ip, :ssh_username, :ssh_password, :ssh_port, :ssh_private_key_file, :tags
      # non-database attributes, used for ssh connection and logging
      attr_accessor :ssh, :logger

      def self.descriptor_errors(h)
        errors = []

        # validate: the parameter h is a hash
        errors << "The parameter h is not a hash" unless h.is_a?(Hash)

        # validate: the parameter h has a key :name
        errors << "The parameter h does not have a key :name" unless h.has_key?(:name)

        # validate: the parameter h[:name] is a string
        errors << "The parameter h[:name] is not a string" unless h[:name].is_a?(String)

        # validate: the paramerer h has a key :net_remote_ip
        errors << "The parameter h does not have a key :net_remote_ip" unless h.has_key?(:net_remote_ip)

        # validate: the paramerer h has a key :ssh_username
        errors << "The parameter h does not have a key :ssh_username" unless h.has_key?(:ssh_username)

        # validate: the parameter h[:ssh_username] is a string
        errors << "The parameter h[:ssh_username] is not a string" unless h[:ssh_username].is_a?(String)

        # if the parameter h has a key :ssh_private_key_file
        if h.has_key?(:ssh_private_key_file) && !h[:ssh_private_key_file].nil?
          # validate: the parameter h[:ssh_private_key_file] is a string
          errors << "The parameter h[:ssh_private_key_file] is not a string" unless h[:ssh_private_key_file].is_a?(String)

          # validate: the parameter h[:ssh_private_key_file] is a string
          errors << "The parameter h[:ssh_private_key_file] is not a string" unless h[:ssh_private_key_file].is_a?(String)
        else
          # validate: the parameter h has a key :ssh_password
          errors << "The parameter h does not have a key :ssh_password nor :ssh_private_key_file" unless h.has_key?(:ssh_password)

          # validate: the parameter h[:ssh_password] is a string
          errors << "The parameter h[:ssh_password] is not a string" unless h[:ssh_password].is_a?(String)
        end

        # if the parameter h has a key :tags
        if h.has_key?(:tags) && !h[:tags].nil?
          # validate: the parameter h[:tags] is an array or a string
          errors << "The parameter h[:tags] is not an array or a string" unless h[:tags].is_a?(Array) || h[:tags].is_a?(String)
        end

        # return
        errors
      end # def self.descriptor_errors(h)

      def initialize(h, i_logger=nil)
        errors = BlackStack::Infrastructure::NodeModule.descriptor_errors(h)
        # raise an exception if any error happneed
        raise "The node descriptor is not valid: #{errors.uniq.join(".\n")}" if errors.length > 0
        # map attributes
        self.name = h[:name]
        self.net_remote_ip = h[:net_remote_ip]
        self.ssh_username = h[:ssh_username]
        self.ssh_password = h[:ssh_password] 
        self.ssh_port = h[:ssh_port]
        self.ssh_private_key_file = h[:ssh_private_key_file]
        # parse the tags
        if h.has_key?(:tags) && !h[:tags].nil?
          self.tags = h[:tags].is_a?(Array) ? h[:tags] : [h[:tags]]
        else
          self.tags = []
        end
        # create a logger
        self.logger = !i_logger.nil? ? i_logger : BlackStack::DummyLogger.new(nil)
      end # def self.create(h)

      def to_hash
        {
          :name => self.name,
          :net_remote_ip => self.net_remote_ip,
          :ssh_username => self.ssh_username,
          :ssh_password => self.ssh_password, 
          :ssh_port => self.ssh_port,
          :ssh_private_key_file => self.ssh_private_key_file,
          :tags => self.tags
        }
      end # def to_hash

      # return true if the node is all set to connect using ssh user and password.
      def using_password?
        !self.net_remote_ip.nil? && !self.ssh_username.nil? && !self.ssh_password.nil?
      end

      # return true if the node is all set to connect using a private key file.
      def using_private_key_file?
        !self.net_remote_ip.nil? && !self.ssh_username.nil? && !self.ssh_private_key_file.nil?
      end

      def connect
        # connect
        if self.using_password?
          self.ssh = Net::SSH.start(self.net_remote_ip, self.ssh_username, :password => self.ssh_password, :port => self.ssh_port)
        elsif self.using_private_key_file?
          self.ssh = Net::SSH.start(self.net_remote_ip, self.ssh_username, :keys => self.ssh_private_key_file, :port => self.ssh_port)
        else
          raise "No ssh credentials available"
        end
        self.ssh
      end # def connect

      def disconnect
        self.ssh.close
      end

      def code(command, sudo=true)
        s = nil
        if sudo
          command.gsub!(/'/, "\\\\'")
          if self.using_password?
            s = "echo '#{self.ssh_password.gsub(/'/, "\\\\'")}' | sudo -S su root -c '#{command}'"
          elsif self.using_private_key_file?
            s = "sudo -S su root -c '#{command}'"
          end
        else
          s = command
        end
        s
      end

      def exec(command, sudo=true)
        code = self.code(command, sudo)
        s = self.ssh.exec!(code)
        s
      end # def exec

      def reboot()
        tries = 0
        max_tries = 20
        success = false

        host = self

        logger.logs 'reboot... '
        #stdout = host.reboot
        begin
          stdout = self.exec("reboot")
        rescue
        end
        logger.done #logf("done (#{stdout})")

        while tries < max_tries && !success
            begin
                tries += 1

                delay = 10
                logger.logs "wait #{delay.to_s} seconds... "
                sleep(delay)
                logger.done

                logger.logs "connecting (try #{tries.to_s})... "
                host.connect
                logger.done

                success = true
            rescue => e
                logger.logf e.to_s #error e
            end
        end # while 
        raise 'reboot failed' if !success
      end # def reboot

      # Return a hash descriptor of the status of the node
      def usage()
        ret = {}

        #self.connect

        ret[:b_total_memory] = self.ssh.exec!('cat /proc/meminfo | grep MemTotal').delete('^0-9').to_i*1024
        ret[:kb_total_memory] = ret[:b_total_memory] / 1024
        ret[:mb_total_memory] = ret[:kb_total_memory] / 1024
        ret[:gb_total_memory] = ret[:mb_total_memory] / 1024

        ret[:kb_free_memory] = self.ssh.exec!('cat /proc/meminfo | grep MemFree').delete('^0-9').to_i
        ret[:mb_free_memory] = ret[:kb_free_memory] / 1024
        ret[:gb_free_memory] = ret[:mb_free_memory] / 1024

        # run bash commend to get the total disk space
        ret[:mb_total_disk] = self.ssh.exec!('df -m / | tail -1 | awk \'{print $2}\'').to_i
        ret[:gb_total_disk] = ret[:mb_total_disk] / 1024
        # run bash command to get the free disk space
        ret[:mb_free_disk] = self.ssh.exec!('df -m / | tail -1 | awk \'{print $4}\'').to_i
        ret[:gb_free_disk] = ret[:mb_free_disk] / 1024
        
        # run bash command to get hostname
        ret[:hostname] = self.ssh.exec!('hostname').strip!

        # run bash command to get the CPU load
        # reference: https://stackoverflow.com/questions/9229333/how-to-get-overall-cpu-usage-e-g-57-on-linux
        ret[:cpu_load_average] = self.ssh.exec!("awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1) \"%\"; }' <(grep 'cpu ' /proc/stat) <(sleep 1;grep 'cpu ' /proc/stat)").to_s

        # TODO: monitor the overall Network I/O load

        # TODO: monitor the overall Disk I/O load

        # mapping cpu status
        ret[:cpu_architecture] = self.ssh.exec!('lscpu | grep Architecture').split(':')[1].strip!
        ret[:cpu_speed] = self.ssh.exec!('lscpu | grep "CPU MHz:"').split(':')[1].strip!.to_f.round
        #ret[:cpu_model] = self.ssh.exec!('lscpu | grep "Model"').split(':')[1].strip!
        #ret[:cpu_type] = ret[:cpu_model].split(' ')[0]
        ret[:cpu_number] = self.ssh.exec!('lscpu | grep "^CPU(s):"').split(':')[1].strip!.to_i

        # mapping disk status
        #self.disk_total = mb_total_disk.to_i
        #self.disk_free = mb_free_disk.to_i

        # mapping lan attributes
        ret[:net_mac_address] = self.ssh.exec!('ifconfig | grep ether').split[1].upcase.strip.gsub(':', '-') 

        #self.disconnect

        ret
      end # def usage

      # return the latest `n`` lines of the file specified by the `filename` parameter
      def tail(filename, n=10)
        self.connect
        s = self.ssh.exec!("tail -n #{n.to_s} #{filename}")
        self.disconnect
        s
      end

    end # module NodeModule

    # TODO: declare these classes (stub and skeleton) using blackstack-rpc
    #
    # Node Stub
    # This class represents a node, without using connection to the database.
    # Use this class at the client side.
    class Node
      include NodeModule
    end # class Node
=begin
    # Node Skeleton
    # This class represents a node, with connection to the database.
    # Use this class at the server side.
    class Node < Sequel::Model(:node)
      include NodeModule
    end
=end
  end # module Infrastructure
end # module BlackStack