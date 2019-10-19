require 'savi-vagrant-notify/plugin'
require 'savi-vagrant-notify/config'

module VagrantPlugins
  module SaviVagrantNotify
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
