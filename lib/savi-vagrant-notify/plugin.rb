require 'vagrant'

$BOOT_SAVED = false

module VagrantPlugins
  module SaviVagrantNotify
    class Plugin < Vagrant.plugin('2')
      name 'savi-vagrant-notify'
      description 'Version of vagrant-notify-forwarder that does not require port forwarding'

      register_boot_hooks = lambda do |hook|
        require_relative 'action/start_host_forwarder'
        require_relative 'action/start_client_forwarder'
        require_relative 'action/check_boot_state'

        hook.before VagrantPlugins::ProviderVirtualBox::Action::Resume,
                    SaviVagrantNotify::Action::CheckBootState
        hook.after Vagrant::Action::Builtin::Provision,
                  SaviVagrantNotify::Action::StartHostForwarder
        hook.after SaviVagrantNotify::Action::StartHostForwarder,
                  SaviVagrantNotify::Action::StartClientForwarder
      end

      register_suspend_hooks = lambda do |hook|
        require_relative 'action/stop_host_forwarder'

        hook.before VagrantPlugins::ProviderVirtualBox::Action::Suspend,
                    SaviVagrantNotify::Action::StopHostForwarder
      end

      register_resume_hooks = lambda do |hook|
        require_relative 'action/start_host_forwarder'

        hook.after VagrantPlugins::ProviderVirtualBox::Action::Provision,
                    SaviVagrantNotify::Action::StartHostForwarder
      end

      register_halt_hooks = lambda do |hook|
        require_relative 'action/stop_host_forwarder'

        hook.before Vagrant::Action::Builtin::GracefulHalt,
                    SaviVagrantNotify::Action::StopHostForwarder
      end

      register_destroy_hooks = lambda do |hook|
        require_relative 'action/stop_host_forwarder'

        hook.before Vagrant::Action::Builtin::GracefulHalt,
                    SaviVagrantNotify::Action::StopHostForwarder
      end

      config(:notify_forwarder) do
        require_relative 'config'
        Config
      end

      action_hook :start_notify_forwarder, :machine_action_up, &register_boot_hooks
      action_hook :start_notify_forwarder, :machine_action_reload, &register_boot_hooks

      action_hook :stop_notify_forwarder, :machine_action_suspend, &register_suspend_hooks
      action_hook :stop_notify_forwarder, :machine_action_resume, &register_resume_hooks

      action_hook :stop_notify_forwarder, :machine_action_halt, &register_halt_hooks
      action_hook :stop_notify_forwarder, :machine_action_reload, &register_halt_hooks

      action_hook :stop_notify_forwarder, :machine_action_destroy, &register_destroy_hooks

    end
  end
end
