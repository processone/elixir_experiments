defmodule ModPresenceHello do
  import Ejabberd.Logger # this allow using info, error, etc for logging
  @behaviour :gen_mod

  def start(host, _opts) do
    info('Starting ejabberd module Presence Hello')
    Ejabberd.Hooks.add(:set_presence_hook, host, __MODULE__, :on_presence, 50)
    :ok
  end

  def stop(host) do
    info('Stopping ejabberd module Presence Hello')
    Ejabberd.Hooks.delete(:set_presence_hook, host, __MODULE__, :on_presence, 50)
    :ok
  end

  def on_presence(user, _server, _resource, _packet) do
    info('Receive presence for #{user}')
    :none
  end
end
