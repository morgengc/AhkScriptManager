# AhkScriptManager

AhkScriptManager 是一款用于管理常用 AHK 脚本执行的桌面工具，它可以方便地控制常用 AHK 脚本的启动、关闭、重载。本项目致力于常用 AHK 脚本的开发，而 `AhkScriptManager.ahk` 的变动可能会比较小。

接触 AHK 一段时间以后，已经积累了不少脚本，有各种大牛的，有自己写的。一些脚本确实会加快日常操作，但是哪些脚本需要常驻，哪些脚本需要临时启动停止，状态栏存在过多的 Tray 图标等等成了一个棘手的问题。

最先见到 AhkScriptManager 是在小众软件上: http://www.appinn.com/ahk-script-manager/ ，它的出现让我的困惑得以消除。我对其进行了一些改造，形成了本文这个工具，解决了上述问题。

<h2 align="center"><img src="https://github.com/morgengc/AhkScriptManager/blob/master/image/%E4%B8%BB%E8%8F%9C%E5%8D%95.png" styl="max-width:80%"/></h2>

工具中出现了很多脚本，对于任何个人来说，这些脚本当中有些是适用的，有些却是不适用的，需要自己裁剪和改造。

AHK 是一门功能强大的脚本语言，然而语法稍显晦涩。本项目也是一个非常好的参考示例，集中了大量常见的用法，可以当做一个快速的语法参考。

AhkScriptManager 仅接管 `scripts` 目录中的脚本，对已运行的其他脚本不会造成影响(但存在热键冲突风险)。因此个人新添加的脚本必须加入到 `scripts` 目录，并重启 AhkScriptManager 以便刷新。

本软件在 XP/Server2003/Win7/Win10 上稳定运行，Win11 下大部分功能都没有啥问题。

**注意**：Win7系统对程序权限控制较为严格，某些指令执行时需要管理员权限，比如 `+03.Oracle服务.ahk` 里使用了 `cmd /c net start` 命令，如果没有以管理员权限运行，程序将不会正确执行。建议将 `AhkScriptManager.exe` 设置为以管理员权限运行（程序上点击右键，选择属性，选择兼容性，勾选以管理员身份运行此程序），这样可以保证 `scripts` 目录里的脚本均以管理员权限运行。Win10系统没有严格测试，但如果能将所有 `AutoHotkey*.exe` 和 `AhkScriptManager.exe` 设置为 Win7 兼容模式，则大部分脚本运行仍然正常。

## 安装说明

 1. 安装 `setup/AutoHotkey111401_Install.exe`。

 2. 将 `setup/AutoHotkey.chm` 拷贝到 `C:\Program Files\AutoHotkey` 目录，此步骤作用是用中文文档覆盖英文文档。

 3. ~~将 `3rd` 目录添加到 PATH 中，方便 AhkScriptManager 调用这些外部程序。~~ AhkScriptManager 启动时已经将 `3rd` 目录自动加入 PATH。

 4. 运行 `AhkScriptManager.exe`，任务栏右下角将出现该程序图标。

## 不同格式的 ahk 脚本命名代表不同含义
 * 正常命名的脚本:	会随 AhkScriptManager 启动而启动，关闭而关闭，适用于常驻脚本。通常这种脚本中含有快捷键，或者含有 GUI，或者含有 Timer。
 
 * `!` 开头的脚本:	需要手动启动（`Alt+Ctrl+左键`），启动后会驻守，可以手动关闭，适用于某段时间需要常驻的脚本。这种脚本在结束时通常要考虑恢复系统的一些状态。
 
 * `+` 开头的脚本:	启动后只执行一次任务，执行完自动退出或手动退出，不会驻守，适用于执行一次性任务。通常用来完成一些简单任务，比如启动应用程序。

## 快捷键说明
参见 [HotKeys.txt](https://github.com/morgengc/AHK-Script-Manager/blob/master/HotKeys.txt)。

**注意**：快捷键组合中，应先按 `Alt`，再按 `Ctrl`，再按其他键。先按 `Ctrl` 再按 `Alt` 唤出的菜单会闪退，谁能告诉我原因。。。

个人愿望，是希望通过 AhkScriptManager 方便桌面操作。但对于快捷键的使用上，主张够用就好，本人并不赞同太多的快捷键设置。

## 目录设置
| 目录 | 说明 |
| ---- | ---- |
| 3rd | 项目使用的其他类型脚本和应用程序 |
| config | "TODO LIST"脚本使用的配置文件目录 |
| ext | 保存外部调用脚本。比如鼠标右键单击要触发一个事件，事件处理放在脚本中 |
| image | 程序界面截图 |
| lib | 项目使用的第三方AHK脚本库 |
| resources | 程序图标 |
| scripts | 脚本目录 |
| setup | AHK安装包及帮助文件 |
| AhkScriptManager.ahk | 主程序源码 |
| AhkScriptManager.exe | 主程序可执行程序 |
| HotKeys.txt | 项目定义的热键 |
| readme.md | 本文件 |
| TabStop Settings.txt | 各种常见文本编辑器按此设置，以便代码缩进风格统一 |

## 软件配置
| 软件 | 版本 |
| ---- | ---- |
| AHK | AutoHotkey_L Unicode, 版本号1.1.14.01 |
| 操作系统 | Windows XP SP3/Windows Server 2003/Windows7 |
| ahk脚本编码 | UTF-8+BOM |


## 其他说明
~~项目最初托管在Google Code上，地址为: https://code.google.com/p/autohotkey-script-manager/ 。~~

项目目前托管地址：https://github.com/morgengc/AhkScriptManager

在 Autohotkey 中文论坛上单独成贴，地址为: http://ahk8.com/thread-5250.html

