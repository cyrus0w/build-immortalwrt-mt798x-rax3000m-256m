# immortalwrt-mt7981-rax3000m_nand 云编译仓库

需要使用 hanwckf 版 uboot：https://github.com/hanwckf/bl-mt798x

* 默认整合所有路由基础功能(`pppoe`、`ipv6`、`防火墙`等)，其他功能均会在`Release`简介处列出。
* 建议使用`Releases`内最新且标注“已测试”的固件。
* 感谢P3TERX,hanwckf,padavanonly,kenzo等大佬。
* 登陆IP:192.168.5.1
  账号：root
  密码：空
* 近期由于kenzo仓库添加了istore,导致和237仓库既有的istore的app在编译时冲突，请编译时注意在diy-part2.sh中加入命令删除某些重复的软件包。
