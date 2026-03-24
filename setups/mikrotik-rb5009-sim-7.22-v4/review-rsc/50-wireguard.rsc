# Stage 50 - WireGuard admin VPN
:global cfgWgPrivateKey
:global cfgWgAdminPublicKey

:if ([:len "$cfgWgPrivateKey"] = 0 || "$cfgWgPrivateKey" = "CHANGE_ME_WG_PRIVATE_KEY") do={
	:error "Missing cfgWgPrivateKey. Import 00-site-overlay.local.rsc first."
}

:if ([:len "$cfgWgAdminPublicKey"] = 0 || "$cfgWgAdminPublicKey" = "CHANGE_ME_ADMIN_CLIENT_PUBLIC_KEY") do={
	:error "Missing cfgWgAdminPublicKey. Import 00-site-overlay.local.rsc first."
}


:if ([:len [/interface wireguard find where name=wg0]] = 0) do={
    :error "Interface wg0 not found. Run stage 10 first."
}

:local wgIfId [/interface wireguard find where name=wg0]
:local wgRouterPublicKey [/interface wireguard get $wgIfId public-key]
:if ("$cfgWgAdminPublicKey" = "$wgRouterPublicKey") do={
    :error "Refusing to set peer key equal to router wg0 public key. Provide correct client key."
}

/interface wireguard
set [find name=wg0] listen-port=51820 mtu=1420 private-key="$cfgWgPrivateKey"

/interface wireguard peers
:if ([:len [find interface=wg0 comment="Admin laptop"]] = 0) do={
    add interface=wg0 public-key="$cfgWgAdminPublicKey" allowed-address=10.10.10.2/32 comment="Admin laptop" persistent-keepalive=25s
} else={
    set [find interface=wg0 comment="Admin laptop"] public-key="$cfgWgAdminPublicKey" allowed-address=10.10.10.2/32 persistent-keepalive=25s
}

# Allow router management over WireGuard and admin VLAN only.
/ip service
set ssh address=192.168.10.0/24,10.10.10.0/24
set winbox address=192.168.10.0/24,10.10.10.0/24
