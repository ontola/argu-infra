locale: en_US.UTF-8

timezone: UTC

apt:
    conf: |
        APT {
          Get {
            Assume-Yes "true";
            Fix-Broken "true";
          };
        };
packages:
    - haproxy
package_upgrade: true
package_update: true
apt_reboot_if_required: true

write_files:
- path: /etc/haproxy/haproxy.cfg
  permissions: '0644'
  content: |
      global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats timeout 30s
        user haproxy
        group haproxy
        daemon
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private
        ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
        ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

      defaults
        log    global
        mode      tcp
        option    http-use-htx
        option    tcplog
        option    dontlognull
        timeout client 20s
        timeout server 20s
        timeout connect 4s
        default-server init-addr last,libc,none
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

      frontend kubernetes-apiserver-https
        bind *:443
        mode tcp
        default_backend kubernetes-ingress

      backend kubernetes-ingress
        mode tcp
        option tcp-check
        balance roundrobin
          server ingress ${cluster_ipv4}:443 check

      listen stats
        bind *:32700
        mode http
        stats enable
        stats uri /
        stats hide-version
        stats auth admin:admin
