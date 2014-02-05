require "mystro-common"
require "chef"

Ridley::Logging.logger.level = Logger.const_get 'ERROR'

module Mystro
  module Plugin
    module Chef
      include Mystro::Plugin::Base

      register(
          ui: {},
          schedule: {},
          jobs: []
      )

      class << self
        attr_reader :chef

        def configure
          @config ||= config_for self
          @chef ||= ::Chef::Config.from_file(File.expand_path(@config[:knife]))
          #@chef   ||= begin
          #  if @config["knife"]
          #    ::Ridley.from_chef_config(knife)
          #  else
          #    ::Ridley.new(@config.to_hash)
          #  end
          #end
        end

        def config
          configure
          @config
        end

        def role_list
          configure
          # TODO: better error handling
          list = ::Chef::Role.list
          list
        end

        def environment_create(name)
          configure
          env = ::Chef::Environment.new
          env.name(name)
          env.description("created by Mystro")
          env.save
          true
        rescue => e
          Mystro::Log.error "*** chef exception: #{e.message}"
          false
        end

        def environment_destroy(name)
          configure
          env = ::Chef::Environment.load(name) rescue nil
          env.destroy if env
          true
        rescue => e
          Mystro::Log.error "*** chef exception: #{e.message}"
          false
        end

        def environment_list
          configure
          ::Chef::Environment.list
        end

        def clients_list
          configure
          ::Chef::ApiClient.list
        end

        def client_delete(name)
          configure
          # TODO: better error handling
          Mystro::Log.debug "chef:client_delete:#{name}"
          client = ::Chef::ApiClient.load(name)
          client.destroy if client
        rescue => e
          Mystro::Log.error "*** chef exception: #{e.message} at #{e.backtrace.first}"
          false
        end

        def node_list
          configure
          # TODO: better error handling
          ::Chef::Node.list
        end

        def node_delete(name)
          configure
          # TODO: better error handling
          node = ::Chef::Node.load(name)
          node.destroy if node
        rescue => e
          Mystro::Log.error "*** chef exception: #{e.message} at #{e.backtrace.first}"
          false
        end
      end

      on "environment:create" do |args|
        environment = args.shift
        name = environment.name
        self.environment_create(name)
      end

      on "environment:destroy" do |args|
        environment = args.shift
        name = environment.name
        self.environment_destroy(name)
      end

      #on "compute:create" do |args|
      #  # do nothing
      #  # the instance will add itself through the chef-client call in userdata package
      #end

      on "compute:destroy" do |args|
        instance = args.shift
        compute = args.shift
        short = compute.short
        long = compute.long
        Mystro::Log.info "chef compute:destroy #{short}"
        self.client_delete(compute.short)
        self.node_delete(compute.short)
        # delete nodes and clients, HARDER!
        Mystro::Log.info "chef compute:destroy #{long}"
        self.client_delete(compute.long)
        self.node_delete(compute.long)
      end

      command "chef", "test chef plugin configuration" do
        self.default_subcommand = "client"
        subcommand "client", "manage chef clients" do
          self.default_subcommand = "list"
          subcommand "list", "list chef clients" do
            def execute
              list = Mystro::Plugin::Chef.clients_list
              rows = []
              list.each do |c|
                rows << {name: c[0], location: c[1]}
              end
              Mystro::Log.warn Mystro::CLI.list(%w{Name Location}, rows)
            end
          end
          subcommand "destroy", "destroy chef client" do
            parameter "name", "name of client"

            def execute
              Mystro::Plugin::Chef.client_delete(name)
            end
          end
        end
        subcommand "node", "manage chef nodes" do
          self.default_subcommand = "list"
          subcommand "list", "list chef nodes" do
            def execute
              list = Mystro::Plugin::Chef.node_list
              rows = []
              list.each do |c|
                rows << {name: c[0], location: c[1]}
              end
              Mystro::Log.warn Mystro::CLI.list(%w{Name Location}, rows)
            end
          end
          subcommand "destroy", "destroy chef node" do
            parameter "name", "name of node"

            def execute
              Mystro::Plugin::Chef.node_delete(name)
            end
          end
        end
        subcommand "role", "manage chef roles" do
          self.default_subcommand = "list"
          subcommand "list", "list chef roles" do
            def execute
              list = Mystro::Plugin::Chef.role_list
              rows = []
              list.each do |c|
                rows << {name: c[0], location: c[1]}
              end
              Mystro::Log.warn Mystro::CLI.list(%w{Name Location}, rows)
            end
          end
          subcommand "destroy", "destroy chef role" do
            parameter "name", "name of role"

            def execute
              Mystro::Plugin::Chef.role_delete(name)
            end
          end
        end
        subcommand "environment", "manage chef environments" do
          self.default_subcommand = "list"
          subcommand "list", "list chef environments" do
            def execute
              list = Mystro::Plugin::Chef.environment_list
              rows = []
              list.each do |c|
                rows << {name: c[0], location: c[1]}
              end
              Mystro::Log.warn Mystro::CLI.list(%w{Name Location}, rows)
            end
          end
          subcommand "destroy", "destroy chef client" do
            parameter "name", "name of environment"

            def execute
              Mystro::Plugin::Chef.environment_destroy(name)
            end
          end
          subcommand "kill", "destroy chef environment and any nodes or clients that contain the name" do
            parameter "name", "name of environment"

            def execute
              clients = Mystro::Plugin::Chef.client_list.map { |e| {name: e[0], location: e[1]} }.select { |e| e[:name] =~ /\.#{name}\./ }
              nodes = Mystro::Plugin::Chef.node_list.map { |e| {name: e[0], location: e[1]} }.select { |e| e[:name] =~ /\.#{name}\./ }
              Mystro::Log.warn "environment: #{name}"
              Mystro::Log.warn "clients"
              Mystro::Log.warn Mystro::CLI.list(%w{Name Location}, clients)
              Mystro::Log.warn "nodes"
              Mystro::Log.warn Mystro::CLI.list(%w{Name Location}, nodes)
              Mystro::Log.warn "Are you sure? This cannot be undone! enter the name of the environment:"
              e = $stdin.gets.chomp
              if e === name
                clients.each do |c|
                  Mystro::Log.warn "client delete: #{c[:name]}"
                  Mystro::Plugin::Chef.client_delete(c[:name])
                end
                nodes.each do |n|
                  Mystro::Log.warn "node delete: #{n[:name]}"
                  Mystro::Plugin::Chef.node_delete(n[:name])
                end
                Mystro::Plugin::Chef.environment_destroy(name)
              end
            end
          end
        end
      end
    end
  end
end