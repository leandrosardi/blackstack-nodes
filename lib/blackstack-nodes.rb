require 'net/ssh'
require 'simple_cloud_logging'
# 
module BlackStack
  # 
  module Infrastructure
    # this module has attributes an methods used by both classes Node and Node.
    module NodeModule
      # :name is this is just a descriptive name for the node. It is not the host name, nor the domain, nor any ip. 
      attr_accessor :name, :net_remote_ip, :ssh_username, :ssh_password, :ssh_port, :ssh_private_key_file
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

        # create a logger
        self.logger = !i_logger.nil? ? i_logger : BlackStack::BaseLogger.new(nil)
      end # def self.create(h)

      def to_hash
        {
          :name => self.name,
          :net_remote_ip => self.net_remote_ip,
          :ssh_username => self.ssh_username,
          :ssh_password => self.ssh_password, 
          :ssh_port => self.ssh_port,
          :ssh_private_key_file => self.ssh_private_key_file,
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

      def exec(command, sudo=true)
        s = nil
        command = command.gsub(/'/, "\\\\'")
        if sudo
          if self.using_password?
            s = self.ssh.exec!("echo '#{self.ssh_password.gsub(/'/, "\\\\'")}' | sudo -S su root -c '#{command}'")
          elsif self.using_private_key_file?
            s = self.ssh.exec!("sudo -S su root -c '#{command}'")
          end
        else
          s = self.ssh.exec!(command)
        end
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