include stdlib

# Install *.example.dev Wildcard PKI certificate
$sslcerts = hiera(certs_for_system)
create_resources(sslmgmt::cert, $sslcerts)

# Install *.example.dev CA Certificate
$cacerts = hiera(ca_certs_for_system)
create_resources(sslmgmt::ca_dh, $cacerts)

include erlang
include elixir
