# nginx

#使用
```
  wget https://raw.githubusercontent.com/xiaomatech/nginx/master/nginx-1.13.8.x86_64.rpm
  yum localinstall -y ./nginx-1.12.2.x86_64.rpm
  yum install -y GeoIP GeoIP-data 
  #geoipupdate
  
  修改 nginx配置 比如:/opt/nginx/conf/common/ssl.conf 的ssl 路径等
  
  /etc/init.d/nginx start
```


#编译
```
  wget https://raw.githubusercontent.com/xiaomatech/nginx/master/nginx_build.sh
  bash nginx_build.sh
```


