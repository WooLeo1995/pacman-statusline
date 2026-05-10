# pacman-statusline
Claude Code statusline配置，前置需求你的终端工具支持 Nerd Font 字体 https://www.nerdfonts.com

## 使用方法

在 Claude 的 setting.json 配置文件中加上

```
{
  ....
  
   "statusLine": {
    "command": "配置文件的位置 。。。xxxxx/pacman-statusline.sh",   # 建议直接放在 .claude/新建一个文件夹例如 statusline 维护
    "padding": 0,
    "type": "command"
  }
}
```
