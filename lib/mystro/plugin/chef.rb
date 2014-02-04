require "mystro/plugin/chef/engine" if defined?(Rails)
require "mystro/plugin/chef/plugin" unless Mystro::Plugin.disabled?("mystro-chef")

module MystroChef
end
