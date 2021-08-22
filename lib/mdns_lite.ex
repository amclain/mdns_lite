defmodule MdnsLite do
  import MdnsLite.DNS

  @moduledoc """
  A simple implementation of an mDNS (multicast DNS (Domain Name Server))
  server.  mDNS uses multicast UDP rather than TCP. Its primary use is to
  provide DNS support for the `local` domain. `MdnsLite` listens on a
  well-known ip address/port. If a request arrives that it recognizes, it
  constructs the appropriate DNS response.

  `MdnsLite` responds to a limited number of DNS requests; they are all handled
  in the `MdnsLite.Query` module. Of particular note is the SRV request. The
  response will be a list of known services and how to contact them (domain and
  port) as described in the configuration file.

  This module is initialized, at runtime, with host information and service
  descriptions found in the `config.exs` file.  The descriptions will be used
  by `MdnsLite` to construct a response to a query.

  Please refer to the `README.md` for further information.
  """

  @doc """
  Set the list of host names

  `host` can have the value of  `:hostname` in which case the value will be
  replaced with the value of `:inet.gethostname()`, otherwise you can provide a
  string value. You can specify an alias hostname in which case `host` will be
  `["hostname", "alias-example"]`. The second value must be a string. When you
  use an alias, an "A" query can be made to  `alias-example.local` as well as
  to `hostname.local`. This can also be configured at runtime via
  `MdnsLite.set_host/1`:

  ```elixir
  iex> MdnsLite.set_host([:hostname, "nerves"])
  :ok
  ```
  """
  defdelegate set_host(host), to: MdnsLite.Configuration

  @doc """
  Add services for mdns_lite to advertise

  The `services` section lists the services that the host offers, such as
  providing an HTTP server. You must supply the `protocol`, `transport` and
  `port` values for each service. You may also specify `weight` and/or `host`.
  They each default to a zero value. Please consult the RFC for an explanation
  of these values. Services can be configured in `config.exs` as shown above,
  or at runtime:

  ```elixir
  iex> services = [
    # service type: _http._tcp.local - used in match
    %{
      name: "Web Server",
      protocol: "http",
      transport: "tcp",
      port: 80,
    },
    # service_type: _ssh._tcp.local - used in match
    %{
      name: "Secure Socket",
      protocol: "ssh",
      transport: "tcp",
      port: 22,
    }
  ]

  iex> MdnsLite.add_mdns_services(services)
  :ok
  ```
  """
  defdelegate add_mdns_services(services), to: MdnsLite.Configuration

  @doc """
  Remove services

  Services can also be removed at runtime via `remove_mdns_services/1` with the
  service name to remove:

  ```elixir
  iex> service_names = ["Web Server", "Secure Socket"]
  iex> MdnsLite.remove_mdns_services(services)
  :ok

  # Remove just a single service
  iex> MdnsLite.remove_mdns_services("Secure Socket")
  :ok
  ```
  """
  defdelegate remove_mdns_services(service_names), to: MdnsLite.Configuration

  @doc """
  Lookup a hostname using mDNS

  The hostname should be a .local name since the query only goes out via mDNS.
  On success, an IP address is returned.
  """
  @spec gethostbyname(String.t()) :: {:ok, :inet.ip()} | {:error, any()}
  def gethostbyname(hostname) do
    dns_query(class: :in, type: :a, domain: to_charlist(hostname))
  end

  def query(q) do
  end
end
