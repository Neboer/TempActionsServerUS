# TempActionsServerUS
grab a temp actions server to use as temporary server in untilsoftware

使用方法：
运行workflow,然后等进sleep后，`ssh temp-gh1.us.ygg`

配置方法：
得到``的方法是，对生成的配置文件`yggdrasil.conf.xz`，执行
```
cat yggdrasil.conf.xz |base64 > tempserverconf.txt
```
这样可以得到压缩并base64后的配置，传进Secret值YGGCONFDATA中
然后将ssh公钥传进Secret `PUBKEY`中
这样，启动服务器就可以连接了。
