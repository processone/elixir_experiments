# Declare module in ejabberd.yml
# modules:
#   ModOfflineZapier: {}
defmodule ModOfflineZapier do
  @behaviour :gen_mod
  
  import Ejabberd.Logger
  require FastXML

  def start(host, _opts) do
    info('Offline Zapier module started.')
    HTTPotion.start

    :ejabberd_hooks.add(:offline_message_hook, host, __MODULE__, :on_offline_message, 50)
    :ok
  end

  def stop(host) do
    info('Offline Zapier module stopped.')
    :ejabberd_hooks.delete(:offline_message_hook, host, __MODULE__, :on_offline_message, 50)
    :ok
  end

  def on_offline_message(from, to, xml = FastXML.xmlel(name: "message", children: children)) do
    info('Offline message #{inspect xml}')
    Enum.each(children,
              fn
                FastXML.xmlel(name: "body", children: [{:xmlcdata, body}]) ->
                  post(:jid.to_string(from), :jid.to_string(to), body)
                child ->
                  child
              end)
    :ok
  end
  
  defp post(sFrom, sTo, message) do
    url = "https://zapier.com/hooks/catch/3ff6d6/"
    body = "{\n\"from\": \"#{sFrom}\",\n\"to\": \"#{sTo}\",\n\"body\": \"Message received: #{message}\"\n}"
      response = HTTPotion.post url, [body: body, headers: ["Accept": "application/json", "Content-Type": "application/json; charset=utf-8"]]
    true = HTTPotion.Response.success?(response)
  end
  
end
