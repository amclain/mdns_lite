defmodule MdnsLite.Client do
  @moduledoc false

  import MdnsLite.DNS

  # Reserved IANA ip address and port for mDNS
  @mdns_ipv4 {224, 0, 0, 251}
  @mdns_port 5353
  @sol_socket 0xFFFF
  @so_reuseport 0x0200
  @so_reuseaddr 0x0004

  @doc """
  Helper for creating an A-record query
  """
  @spec query_a(String.t()) :: DNS.dns_query()
  def query_a(hostname) do
    dns_query(class: :in, type: :a, domain: to_charlist(hostname))
  end

  @doc """
  Helper for creating a AAAA-record query
  """
  @spec query_aaaa(String.t()) :: DNS.dns_query()
  def query_aaaa(hostname) do
    dns_query(class: :in, type: :aaaa, domain: to_charlist(hostname))
  end

  @spec encode(DNS.dns_query(), unicast: boolean()) :: binary()
  def encode(dns_query() = query, options \\ []) do
    dns_rec(
      # RFC6762: Query ID SHOULD be set to zero
      header: dns_header(id: 0, qr: false, aa: false, rcode: 0),
      # Query list. Must be empty according to RFC 6762 Section 6.
      qdlist: [request_unicast(query, options[:unicast])],
      # A list of answer entries. Can be empty.
      anlist: [],
      # nslist Can be empty.
      nslist: [],
      # arlist A list of resource entries. Can be empty.
      arlist: []
    )
    |> :inet_dns.encode()
  end

  defp request_unicast(dns_query(class: class) = query, value) do
    dns_query(query, class: set_unicast_bit(class, value))
  end

  defp set_unicast_bit(:in, true), do: 0x8001
  defp set_unicast_bit(class, _not_true), do: class
end
