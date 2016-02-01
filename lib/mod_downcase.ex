# Declare module in ejabberd.yml
# modules:
#   ModDowncase: {}
defmodule ModDowncase do
  @behaviour :gen_mod
  
  import Ejabberd.Logger
  require FastXML

  def start(_host, _opts) do
    info('Downcase module started.')
    :ejabberd_hooks.add(:filter_packet, :global, __MODULE__, :on_filter_packet, 50)
    :ok
  end

  def stop(_host) do
    info('Downcase module stopped.')
    :ejabberd_hooks.delete(:filter_packet, :global, __MODULE__, :on_filter_packet, 50)
    :ok
  end

  def on_filter_packet({from, to, xml = FastXML.xmlel(name: "message", children: children)}) do
    info('Filtering message #{inspect xml}')
    downChildren = Enum.map(children,
                            fn
                              child = FastXML.xmlel(name: "body", children: [{:xmlcdata, body}]) ->
                                FastXML.xmlel(child, children: [{:xmlcdata, String.downcase(body)}])
                              child ->
                                child
                            end)
    {from, to, FastXML.xmlel(xml, children: downChildren)}
  end
  def on_filter_packet(packet), do: packet
  
end
