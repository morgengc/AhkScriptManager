# AHK-Script-Manager
AHK Script Manager是一款用于管理常用ahk脚本运行的工具.

scripts目录:
正常命名的脚本:	会随AHK Script Manager启动而启动，关闭而关闭. 适用于常驻脚本.
!开头的脚本:	需要手动启动，启动后会驻守，可以手动关闭. 适用于某段时间需要常驻的脚本.
+开头的脚本:	启动后只执行一次任务，执行完自动退出，不会驻守. 适用于执行一次性任务.

ext目录:
用于保存外部调用脚本. 比如鼠标右键单击要触发一个事件，事件处理放在脚本中

------------

AHK版本:		AutoHotkey_L Unicode, 版本号1.1.14.01
操作系统:		Windows XP SP3
ahk脚本编码:	UTF-8+BOM

------------

安装说明:
1. 安装setup/AutoHotkey111401_Install.exe
2. 将setup/AutoHotkey.chm拷贝到C:\Program Files\AutoHotkey目录，此步骤作用是用中文文档覆盖英文文档
3. 将3rd/*.exe和3rd/*.cmd拷贝到C:\WINDOWS\system32目录，此步骤作用是将脚本调用的外部程序和脚本拷贝到系统目录
4. 运行AHK Script Manager.exe，任务栏右下角将出现该程序图标

快捷键说明参见HotKeys.txt

注意: 
1. "+一键显隐.ahk"要修改注册表以实现文件显隐、后缀显隐，因此需要关闭防火墙和杀毒软件才有效果.
2. "+CMD目录.ahk"打开cmd窗口后会自动输入命令，命令均是英文，因此需要设置默认输入语言为英文.

--------------

文件说明:
3rd                         项目使用的其他类型脚本和应用程序
config                      "TODO LIST"脚本使用的配置文件目录
image                       程序界面截图
lib                         项目使用的第三方AHK脚本库
resources                   程序图标
scripts                     脚本目录
setup                       AHK安装包及帮助文件
Wiki                        文档
AHK Script Manager.ahk      主程序源码
AHK Script Manager.exe      主程序可执行程序
HotKeys.txt                 项目定义的热键
readme.txt                  本文件
TabStop Settings            各种常见文本编辑器按此设置，以便代码缩进风格统一

--------------

项目托管在Google Code上，地址为: https://code.google.com/p/autohotkey-script-manager/
脚本描述Wiki: https://code.google.com/p/autohotkey-script-manager/wiki/ScriptDesc
源码下载: svn checkout https://autohotkey-script-manager.googlecode.com/svn/trunk

在Autohotkey中文论坛上单独成贴，地址为: http://ahk8.com/thread-5250.html

本软件在XP上稳定运行，其他操作系统上未经测试!
