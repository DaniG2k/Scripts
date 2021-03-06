#!/bin/bash
# Openresty automated installer script.

# Verify script is running with root priviledges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Exiting." 1>&2
  exit 1
fi

# Install base package.
yum install http://packages.squiz.co.uk/el/squizuk-release-latest.rpm
yum install -y openresty

openresty_base="/etc/openresty"
openresty_conf="$openresty_base/conf.d"

if [ ! -d "$openresty_conf" ]; then
  mkdir $openresty_conf
fi

# Get host name
echo "Type the hostname for this server (eg. demo.funnelback.co.uk)"
read hostname

cat > "$openresty_conf/http.conf" <<EOF
#Main HTTP proxy configuration
#
server {
# Override the 'localhost' server configured in nginx.conf
# which displays only the status page to local hosts
  listen 80 default_server;
  server_name $hostname;

  proxy_set_header Host \$host;
  proxy_set_header x-forwarded-for \$proxy_add_x_forwarded_for;
  proxy_set_header X-Real-IP \$remote_addr;

# Limit the number of requests, using the all zone and setting a burst rate of 100
# limit_req zone=all burst=100 nodelay;

# Send all requests to http-upstream
  location / {
    proxy_pass http://http-upstream;
  }
}
EOF

cat > "$openresty_conf/https.conf" <<EOF
# Main HTTPS proxy configuration
#
server {
  listen 443;
  server_name $hostname;

  ssl on;
  ssl_certificate /etc/openresty/star.funnelback.co.uk.crt;
  ssl_certificate_key /etc/openresty/star.funnelback.co.uk.key;
  ssl_session_timeout 5m;

  ssl_protocols SSLv2 SSLv3 TLSv1;
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;
  ssl_verify_client off;

# Limit the number of requests, using the all zone and setting a burst rate of 100
#limit_req zone=all burst=100 nodelay;

#Send all requests to https-upstream
  location / {
    proxy_pass https://https-upstream;
  }
}
EOF

cat > "$openresty_conf/upstream.conf" <<EOF
upstream http-upstream {
  server 127.0.0.1:8080;
}

upstream https-upstream {
  server 127.0.0.1:8443;
}
EOF

if [ ! -d "/opt/funnelback" ]; then
  echo "Please specifiy the Funnelback installation directory"
  echo "(Eg. /opt/funnelback)"
  read fb_install_dir
else
  fb_install_dir="/opt/funnelback"
fi

cat > "$fb_install_dir/conf/global.cfg" <<EOF
urls.search_port=8080
urls.admin_port=8443
EOF

/etc/init.d/funnelback-jetty-webserver restart

# Install certificates

cat > "$openresty_base/star.funnelback.co.uk-nointermediate.crt" <<"EOF"
-----BEGIN CERTIFICATE-----
MIIFPDCCBCSgAwIBAgIDCq/wMA0GCSqGSIb3DQEBBQUAMDwxCzAJBgNVBAYTAlVT
MRcwFQYDVQQKEw5HZW9UcnVzdCwgSW5jLjEUMBIGA1UEAxMLUmFwaWRTU0wgQ0Ew
HhcNMTMwMjIwMDQ1NDAyWhcNMTQwMjIzMTAwMDUwWjCBwTEpMCcGA1UEBRMgYWJO
V1Y0Yi9ieFRZRXdRR2hDSTV2NGdKWWYwWFRoRHYxEzARBgNVBAsTCkdUNjU4MTk1
MDQxMTAvBgNVBAsTKFNlZSB3d3cucmFwaWRzc2wuY29tL3Jlc291cmNlcy9jcHMg
KGMpMTMxLzAtBgNVBAsTJkRvbWFpbiBDb250cm9sIFZhbGlkYXRlZCAtIFJhcGlk
U1NMKFIpMRswGQYDVQQDDBIqLmZ1bm5lbGJhY2suY28udWswggEiMA0GCSqGSIb3
DQEBAQUAA4IBDwAwggEKAoIBAQDnC64lsZ/HxOBqemqY9+K9c9TrWSQtTICRzG1G
oF7Jl/6n3xhyMnPJesNjObnKPbvXcPwy95Dl1PJ3dzjHUJpJyiFGMRi1pmWWZoWB
lSriOC5oLSkQznmjn178r/hiOxvz7x9K4Ny0LoE6Ht3zo7J0ZOhLMEZnSFrnMQ2w
H5nTn86XW/q8SVuC4rjzOeUQ5Cd5hM72un+YN83QK9cCFHlcHWnrUJVHU0sU+swa
kMiT7B7rDygMbfC/D4/79NIO2bl2d/vEMlZsJvzBIkUXQjR7lSq2TLcgUJfR6K3C
VpbCpMf+kpaA51MArj9SbVjBMHIO2Mmd3jmlJl8q2whWOINBAgMBAAGjggG/MIIB
uzAfBgNVHSMEGDAWgBRraT1qGEJK3Y8CZTn9NSSGeJEWMDAOBgNVHQ8BAf8EBAMC
BaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMC8GA1UdEQQoMCaCEiou
ZnVubmVsYmFjay5jby51a4IQZnVubmVsYmFjay5jby51azBDBgNVHR8EPDA6MDig
NqA0hjJodHRwOi8vcmFwaWRzc2wtY3JsLmdlb3RydXN0LmNvbS9jcmxzL3JhcGlk
c3NsLmNybDAdBgNVHQ4EFgQUWGdCfjNqfvziiZeKC700/9n8EMEwDAYDVR0TAQH/
BAIwADB4BggrBgEFBQcBAQRsMGowLQYIKwYBBQUHMAGGIWh0dHA6Ly9yYXBpZHNz
bC1vY3NwLmdlb3RydXN0LmNvbTA5BggrBgEFBQcwAoYtaHR0cDovL3JhcGlkc3Ns
LWFpYS5nZW90cnVzdC5jb20vcmFwaWRzc2wuY3J0MEwGA1UdIARFMEMwQQYKYIZI
AYb4RQEHNjAzMDEGCCsGAQUFBwIBFiVodHRwOi8vd3d3Lmdlb3RydXN0LmNvbS9y
ZXNvdXJjZXMvY3BzMA0GCSqGSIb3DQEBBQUAA4IBAQAObFxfdRZ0BGkWcjtPrw8h
pwOFJQ6Os4grB8gkEx12rS38/hyutmHaXSJQfaWyR/QLobKvSDt/iptqc5Dlqa2t
7Xxj2CajmkFCTa+sY6+6CSmr3YuyHyLyHQ75XyS+uMO+1owdzEx+OvrjjVyB4mBa
gPTN3XcSrpLqvZIdnI2TMcuJyzKSEMAeHLMdSPvoCYxiWHxBNVyfoPY57nCfnCdO
4nCTgAy8CQoCIIy1bIRzMGtFB8weEi9vbmLCwPsNUThcjPGvo4p1iUW+b5FKjTMu
6MHuCBhoYuns8yTQ/po/g2EflBS4lFvJmQXQh6Y9JD01RALKINRSQUZlTV19/XvP
-----END CERTIFICATE-----
EOF

cat > "$openresty_base/star.funnelback.co.uk-nointermediate.crt" <<"EOF"
-----BEGIN CERTIFICATE-----
MIIFPDCCBCSgAwIBAgIDCq/wMA0GCSqGSIb3DQEBBQUAMDwxCzAJBgNVBAYTAlVT
MRcwFQYDVQQKEw5HZW9UcnVzdCwgSW5jLjEUMBIGA1UEAxMLUmFwaWRTU0wgQ0Ew
HhcNMTMwMjIwMDQ1NDAyWhcNMTQwMjIzMTAwMDUwWjCBwTEpMCcGA1UEBRMgYWJO
V1Y0Yi9ieFRZRXdRR2hDSTV2NGdKWWYwWFRoRHYxEzARBgNVBAsTCkdUNjU4MTk1
MDQxMTAvBgNVBAsTKFNlZSB3d3cucmFwaWRzc2wuY29tL3Jlc291cmNlcy9jcHMg
KGMpMTMxLzAtBgNVBAsTJkRvbWFpbiBDb250cm9sIFZhbGlkYXRlZCAtIFJhcGlk
U1NMKFIpMRswGQYDVQQDDBIqLmZ1bm5lbGJhY2suY28udWswggEiMA0GCSqGSIb3
DQEBAQUAA4IBDwAwggEKAoIBAQDnC64lsZ/HxOBqemqY9+K9c9TrWSQtTICRzG1G
oF7Jl/6n3xhyMnPJesNjObnKPbvXcPwy95Dl1PJ3dzjHUJpJyiFGMRi1pmWWZoWB
lSriOC5oLSkQznmjn178r/hiOxvz7x9K4Ny0LoE6Ht3zo7J0ZOhLMEZnSFrnMQ2w
H5nTn86XW/q8SVuC4rjzOeUQ5Cd5hM72un+YN83QK9cCFHlcHWnrUJVHU0sU+swa
kMiT7B7rDygMbfC/D4/79NIO2bl2d/vEMlZsJvzBIkUXQjR7lSq2TLcgUJfR6K3C
VpbCpMf+kpaA51MArj9SbVjBMHIO2Mmd3jmlJl8q2whWOINBAgMBAAGjggG/MIIB
uzAfBgNVHSMEGDAWgBRraT1qGEJK3Y8CZTn9NSSGeJEWMDAOBgNVHQ8BAf8EBAMC
BaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMC8GA1UdEQQoMCaCEiou
ZnVubmVsYmFjay5jby51a4IQZnVubmVsYmFjay5jby51azBDBgNVHR8EPDA6MDig
NqA0hjJodHRwOi8vcmFwaWRzc2wtY3JsLmdlb3RydXN0LmNvbS9jcmxzL3JhcGlk
c3NsLmNybDAdBgNVHQ4EFgQUWGdCfjNqfvziiZeKC700/9n8EMEwDAYDVR0TAQH/
BAIwADB4BggrBgEFBQcBAQRsMGowLQYIKwYBBQUHMAGGIWh0dHA6Ly9yYXBpZHNz
bC1vY3NwLmdlb3RydXN0LmNvbTA5BggrBgEFBQcwAoYtaHR0cDovL3JhcGlkc3Ns
LWFpYS5nZW90cnVzdC5jb20vcmFwaWRzc2wuY3J0MEwGA1UdIARFMEMwQQYKYIZI
AYb4RQEHNjAzMDEGCCsGAQUFBwIBFiVodHRwOi8vd3d3Lmdlb3RydXN0LmNvbS9y
ZXNvdXJjZXMvY3BzMA0GCSqGSIb3DQEBBQUAA4IBAQAObFxfdRZ0BGkWcjtPrw8h
pwOFJQ6Os4grB8gkEx12rS38/hyutmHaXSJQfaWyR/QLobKvSDt/iptqc5Dlqa2t
7Xxj2CajmkFCTa+sY6+6CSmr3YuyHyLyHQ75XyS+uMO+1owdzEx+OvrjjVyB4mBa
gPTN3XcSrpLqvZIdnI2TMcuJyzKSEMAeHLMdSPvoCYxiWHxBNVyfoPY57nCfnCdO
4nCTgAy8CQoCIIy1bIRzMGtFB8weEi9vbmLCwPsNUThcjPGvo4p1iUW+b5FKjTMu
6MHuCBhoYuns8yTQ/po/g2EflBS4lFvJmQXQh6Y9JD01RALKINRSQUZlTV19/XvP
-----END CERTIFICATE-----

-----BEGIN CERTIFICATE-----
MIIDfTCCAuagAwIBAgIDErvmMA0GCSqGSIb3DQEBBQUAME4xCzAJBgNVBAYTAlVT
MRAwDgYDVQQKEwdFcXVpZmF4MS0wKwYDVQQLEyRFcXVpZmF4IFNlY3VyZSBDZXJ0
aWZpY2F0ZSBBdXRob3JpdHkwHhcNMDIwNTIxMDQwMDAwWhcNMTgwODIxMDQwMDAw
WjBCMQswCQYDVQQGEwJVUzEWMBQGA1UEChMNR2VvVHJ1c3QgSW5jLjEbMBkGA1UE
AxMSR2VvVHJ1c3QgR2xvYmFsIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEA2swYYzD99BcjGlZ+W988bDjkcbd4kdS8odhM+KhDtgPpTSEHCIjaWC9m
OSm9BXiLnTjoBbdqfnGk5sRgprDvgOSJKA+eJdbtg/OtppHHmMlCGDUUna2YRpIu
T8rxh0PBFpVXLVDviS2Aelet8u5fa9IAjbkU+BQVNdnARqN7csiRv8lVK83Qlz6c
JmTM386DGXHKTubU1XupGc1V3sjs0l44U+VcT4wt/lAjNvxm5suOpDkZALeVAjmR
Cw7+OC7RHQWa9k0+bw8HHa8sHo9gOeL6NlMTOdReJivbPagUvTLrGAMoUgRx5asz
PeE4uwc2hGKceeoWMPRfwCvocWvk+QIDAQABo4HwMIHtMB8GA1UdIwQYMBaAFEjm
aPkr0rKV10fYIyAQTzOYkJ/UMB0GA1UdDgQWBBTAephojYn7qwVkDBF9qn1luMrM
TjAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBBjA6BgNVHR8EMzAxMC+g
LaArhilodHRwOi8vY3JsLmdlb3RydXN0LmNvbS9jcmxzL3NlY3VyZWNhLmNybDBO
BgNVHSAERzBFMEMGBFUdIAAwOzA5BggrBgEFBQcCARYtaHR0cHM6Ly93d3cuZ2Vv
dHJ1c3QuY29tL3Jlc291cmNlcy9yZXBvc2l0b3J5MA0GCSqGSIb3DQEBBQUAA4GB
AHbhEm5OSxYShjAGsoEIz/AIx8dxfmbuwu3UOx//8PDITtZDOLC5MH0Y0FWDomrL
NhGc6Ehmo21/uBPUR/6LWlxz/K7ZGzIZOKuXNBSqltLroxwUCEm2u+WR74M26x1W
b8ravHNjkOR/ez4iyz0H7V84dJzjA1BOoa+Y7mHyhD8S
-----END CERTIFICATE-----

-----BEGIN CERTIFICATE-----
MIID1TCCAr2gAwIBAgIDAjbRMA0GCSqGSIb3DQEBBQUAMEIxCzAJBgNVBAYTAlVT
MRYwFAYDVQQKEw1HZW9UcnVzdCBJbmMuMRswGQYDVQQDExJHZW9UcnVzdCBHbG9i
YWwgQ0EwHhcNMTAwMjE5MjI0NTA1WhcNMjAwMjE4MjI0NTA1WjA8MQswCQYDVQQG
EwJVUzEXMBUGA1UEChMOR2VvVHJ1c3QsIEluYy4xFDASBgNVBAMTC1JhcGlkU1NM
IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAx3H4Vsce2cy1rfa0
l6P7oeYLUF9QqjraD/w9KSRDxhApwfxVQHLuverfn7ZB9EhLyG7+T1cSi1v6kt1e
6K3z8Buxe037z/3R5fjj3Of1c3/fAUnPjFbBvTfjW761T4uL8NpPx+PdVUdp3/Jb
ewdPPeWsIcHIHXro5/YPoar1b96oZU8QiZwD84l6pV4BcjPtqelaHnnzh8jfyMX8
N8iamte4dsywPuf95lTq319SQXhZV63xEtZ/vNWfcNMFbPqjfWdY3SZiHTGSDHl5
HI7PynvBZq+odEj7joLCniyZXHstXZu8W1eefDp6E63yoxhbK1kPzVw662gzxigd
gtFQiwIDAQABo4HZMIHWMA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUa2k9ahhC
St2PAmU5/TUkhniRFjAwHwYDVR0jBBgwFoAUwHqYaI2J+6sFZAwRfap9ZbjKzE4w
EgYDVR0TAQH/BAgwBgEB/wIBADA6BgNVHR8EMzAxMC+gLaArhilodHRwOi8vY3Js
Lmdlb3RydXN0LmNvbS9jcmxzL2d0Z2xvYmFsLmNybDA0BggrBgEFBQcBAQQoMCYw
JAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmdlb3RydXN0LmNvbTANBgkqhkiG9w0B
AQUFAAOCAQEAq7y8Cl0YlOPBscOoTFXWvrSY8e48HM3P8yQkXJYDJ1j8Nq6iL4/x
/torAsMzvcjdSCIrYA+lAxD9d/jQ7ZZnT/3qRyBwVNypDFV+4ZYlitm12ldKvo2O
SUNjpWxOJ4cl61tt/qJ/OCjgNqutOaWlYsS3XFgsql0BYKZiZ6PAx2Ij9OdsRu61
04BqIhPSLT90T+qvjF+0OJzbrs6vhB6m9jRRWXnT43XcvNfzc9+S7NIgWW+c+5X4
knYYCnwPLKbK3opie9jzzl9ovY8+wXS7FXI6FoOpC+ZNmZzYV+yoAVHHb1c0XqtK
LEL2TxyJeN4mTvVvk0wVaydWTQBUbHq3tw==
-----END CERTIFICATE-----
EOF

cat > "$openresty_base/star.funnelback.co.uk-nointermediate.key" <<"EOF"
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEA5wuuJbGfx8TganpqmPfivXPU61kkLUyAkcxtRqBeyZf+p98Y
cjJzyXrDYzm5yj2713D8MveQ5dTyd3c4x1CaScohRjEYtaZllmaFgZUq4jguaC0p
EM55o59e/K/4Yjsb8+8fSuDctC6BOh7d86OydGToSzBGZ0ha5zENsB+Z05/Ol1v6
vElbguK48znlEOQneYTO9rp/mDfN0CvXAhR5XB1p61CVR1NLFPrMGpDIk+we6w8o
DG3wvw+P+/TSDtm5dnf7xDJWbCb8wSJFF0I0e5Uqtky3IFCX0eitwlaWwqTH/pKW
gOdTAK4/Um1YwTByDtjJnd45pSZfKtsIVjiDQQIDAQABAoIBAQDdZmr1wfVbyERI
pJAbj4behu3krOIm6mVV0XBxumG6ioVDtlxFqiUcUCCFqB5qN6gV9jYmXOej5eCH
LF7jWFDRHvmtuoR0JUS5z/plR1z1tGJ7/7KXYVRcv+6U88dv0jaiFWWGKl4z51B8
MnH788ShFsUmr9b3R/WcD3yPZmjQyULUx6dcW5WbAGRTkkN+5Hdp7+BkYx9WWwjK
zc08paAXlxyD1N8erdrXvVjE/XMaXzekRZtIdRerIVseOAOVssoYCxKS9s3kBqi2
dGXlvsBboZPZEKqnVOySKy4FPUndeXSSnQN08AAj8U9Ep3XM7nY53KhqhcFDNj9/
2Mrd3//FAoGBAP9ac6Qo+Joyx/k7eIJT4ti2rDVJkocuiqXpHmNvgJpx7jn4fupV
5zO3K8VgZxK2GvnZgF2eE90xDpoqKDwSSHTf/cSiUABA1aB3pg8Xijjms9B/vjhg
MJpflcFFaMzeFqsI9WwOEgxdoNKVNhsiNb7ZgP9xz86bHyQXfkEE+6dfAoGBAOeh
eDeUJbJUciH2ZgzhlirPWvP7sYQsV4LB3pwYCuTEf1pMUn9bNUpgLSGY5RFtL4RJ
Vnk0gKmrjaFvtX+F3LGdcoM4wU1jsAsaBP8BCF9UJ+2+DpzJAUh75nvEPVWfnkzZ
K7QyiOFhUsAtrxNv6ZhOnewqCKOCXVhgTXw3NvlfAoGALLzSKd6rv4hKFNZghKTh
x4opnaRoMZrr26l+E3nDlEuFq05oHfIy8ZKT7p63MEYLb961aLF7VXN01XmxVuT1
INTlhv/Q+FpjkxujUl2Tb+irdEoNL59apJE+kX/xnoMCgbCuHuJQMy5sMLjHo/VY
aTl+KkLsX4w55n7fNdEDrg0CgYEAsT6AxF7L3cL6tvxaKL8ybr3PBmXx94cKy9bY
Ji/LnjSykwFWG3hKtggUYOIjXwti0eJglkzTq4HH1eGqS9O+BffKGZmDaVm/6y7U
5eD/bBr0ltrZSaYSIkoVG14V5QBIXNvNsoz86yHS9ZW/o6r+X/rAo2eixqPKFAdV
I5kIqxcCgYEAi4yYxUSmfarrQ0zNCUKA1NJZJSqnuWvDl6p+5DnPPElbN9Xaf+5D
c4GQ0vqQOD8f6+iO5yI7ITG8s3VfREFMhg+bwPKvbMHsi93vAOnAmP9uPSq+a2bm
f75bX4d/+uZuMUotYToCdCre3ySBlfJMZmdhxsX0vSi0pbCorsrWMoI=
-----END RSA PRIVATE KEY-----
EOF
