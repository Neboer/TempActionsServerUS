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

## 在github actions中使用

本项目旨在可以方便的在github actions中创建救援环境，以便一旦actions构建错误，无法有效的主动调试，只能被动阅读日志调试。
使用方法为在workfiow runs列表中的开头添加一个
```yaml
      - name: Prepare Rescue SSH
        run: curl -sSL https://github.com/Neboer/TempActionsServerUS/raw/refs/heads/main/install-ygg-ssh-env.sh | bash -e
        env:
          YGGCONFDATA: ${{ secrets.YGGCONFDATA }}
          PUBKEY: ${{ secrets.PUBKEY }}
```
在其结尾处添加
```yaml
      - name: Always Wait
        if: always()
        run: sleep 5.5h
```
然后配置如下secret：
```
gh secret set YGGCONFDATA
gh secret set PUBKEY
```

这样，每次github actions执行完成，你都可以获得5小时的调试时间。
