
yum -y install python-pip
pip install shadowsocks

cat <<EOF>> /etc/shadowscok.json
{
    "server":"xxx.xxx.xxx.xxx",
    "server_port":"2333",
    "local_address": "127.0.0.1",
    "local_port":"9050",
    "password":"xxxxxxxxx",
    "timeout":"300",
    "method":"rc4-md5",
    "fast_open": false,
    "workers": 5
}
EOF
sslocal -c /root/shadowscok.json 
yum -y install proxychains
sed -i "s/4.2.2.2/8.8.8.8/g" /bin/proxyresolv
echo "127.0.0.1 9050" >> /etc/proxychains.conf
proxychains curl www.google.com
