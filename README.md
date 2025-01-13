# TempActionsServerUS
grab a temp actions server to use as temporary server in untilsoftware

使用方法：
运行workflow,然后等进sleep后，`ssh runner@temp-gh1.us.ygg`

配置方法：

得到`YGGCONFDATA`的方法是，首先生成配置文件
`yggdrasil.conf`
然后执行
`xz -z9 yggdrasil.conf`
将其压缩，对生成的配置文件压缩版`yggdrasil.conf.xz`，执行
```
cat yggdrasil.conf.xz | base64 > tempserverconf.txt
```
这样tempserverconf就是压缩并base64后的配置环境变量值，传进Secret值YGGCONFDATA中
然后将ssh公钥传进Secret `PUBKEY`中
这样，启动服务器就可以连接了。
