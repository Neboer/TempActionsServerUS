# TempActionsServerUS
通过 Tailscale 登录临时 GitHub Actions runner。Yggdrasil 版本保留在 [`ygg`](../../tree/ygg) 分支。

## 配置

1. 在 Tailscale 访问策略中创建 `tag:temp-actions`，只允许指定账号或设备访问该标签的 TCP 22，不授予 runner 到其他设备的权限。Tailscale 规则是叠加的；同时检查现有的宽泛规则。
2. 创建仅有 `Auth Keys: Write` 权限且限定到 `tag:temp-actions` 的 Tailscale OAuth 客户端。将 ID 和 secret 存入 `TS_OAUTH_CLIENT_ID` 和 `TS_OAUTH_SECRET`。
3. 将登录者的 SSH 公钥存入 `PUBKEY`。生成专用于该 runner 的 Ed25519 主机密钥，将其私钥存入 `SSH_HOST_KEY`，将其公钥固定到客户端：

   ```sh
   ssh-keygen -t ed25519 -N '' -f ./temp-actions-host
   gh secret set SSH_HOST_KEY < ./temp-actions-host
   printf 'temp-gh1 %s\n' "$(cat ./temp-actions-host.pub)" >> ~/.ssh/known_hosts_temp_actions
   ```

   不要提交私钥。`SSH_HOST_KEY` 与登录者自己的 SSH 私钥无关。

## 使用

本地已连接同一 tailnet 并启用 MagicDNS 后，将下列配置放到 `~/.ssh/config` 的通配规则之前。用实际的 tailnet DNS 后缀替换 `YOUR-TAILNET.ts.net`：

```ssh-config
Host gh1
    HostName temp-gh1.YOUR-TAILNET.ts.net
    User runner
    AddressFamily inet
    HostKeyAlias temp-gh1
    UserKnownHostsFile ~/.ssh/known_hosts_temp_actions
    StrictHostKeyChecking yes
```

```sh
gh workflow run tailscale-actions.yml --ref tailscale -f duration=15m
ssh gh1
```

等 `Start tailnet-only SSH` 步骤通过后再连接。默认开放窗口为 5.5 小时；运行结束后，临时节点退出 tailnet。
