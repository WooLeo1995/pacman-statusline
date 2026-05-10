# pacman-statusline
Claude Code statusline配置

## 使用方法

在 Claude 的 setting.json 配置文件中加上

```
{
  ....
  
   "statusLine": {
    "command": "~/.claude/statusline/native-statusline.sh",
    "padding": 0,
    "type": "command"
  }
}
```
