unless defined?(Mystro::Chef::Version)
  # MystroVolley::Version conflicts with Version model
  module Mystro
    module Chef
      module Version
        MAJOR  = 0
        MINOR  = 1
        TINY   = 0
        TAG    = nil
        STRING = [MAJOR, MINOR, TINY, TAG].compact.join('.')
      end
    end
  end
end