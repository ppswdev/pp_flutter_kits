#!/bin/bash

# Xcode 完全删除脚本
# Author: 肖品
# Date: 2025-08-14
# 1.存储位置: scripts/remove_xcode.sh
# 2.授予权限：chmod +x scripts/remove_xcode.sh
# 3.执行命令：sudo ./scripts/remove_xcode.sh
# 使用方法: sudo ./remove_xcode.sh

echo "开始删除 Xcode..."

# 检查是否以管理员权限运行
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行此脚本"
    exit 1
fi

# 备份重要数据
echo "备份重要数据..."
BACKUP_DIR="$HOME/Desktop/Xcode_Backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 备份 CodeSnippets
if [ -d "$HOME/Library/Developer/Xcode/UserData/CodeSnippets" ]; then
    cp -r "$HOME/Library/Developer/Xcode/UserData/CodeSnippets" "$BACKUP_DIR/"
    echo "CodeSnippets 已备份"
fi

# 备份 KeyBindings
if [ -d "$HOME/Library/Developer/Xcode/UserData/KeyBindings" ]; then
    cp -r "$HOME/Library/Developer/Xcode/UserData/KeyBindings" "$BACKUP_DIR/"
    echo "KeyBindings 已备份"
fi

# 备份主题设置
if [ -d "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes" ]; then
    cp -r "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes" "$BACKUP_DIR/"
    echo "主题设置已备份"
fi

# 备份归档文件
if [ -d "$HOME/Library/Developer/Xcode/Archives" ]; then
    cp -r "$HOME/Library/Developer/Xcode/Archives" "$BACKUP_DIR/"
    echo "归档文件已备份"
fi

# 强制退出 Xcode 进程
echo "正在退出 Xcode 进程..."
killall Xcode 2>/dev/null
killall -9 com.apple.dt.Xcode 2>/dev/null
sleep 2

# 删除主应用程序
echo "删除 Xcode 应用程序..."
rm -rf /Applications/Xcode.app

# 删除开发者工具
echo "删除命令行工具..."
rm -rf /Library/Developer/CommandLineTools
rm -rf /Library/Developer/Xcode

# 删除用户数据
echo "删除用户数据..."
rm -rf ~/Library/Preferences/com.apple.dt.Xcode.plist
rm -rf ~/Library/Preferences/com.apple.dt.XCBuild.plist
rm -rf ~/Library/Caches/com.apple.dt.Xcode
rm -rf ~/Library/Caches/com.apple.dt.XCBuild
rm -rf ~/Library/Application\ Support/Xcode
rm -rf ~/Library/Application\ Support/Developer
rm -rf ~/Library/Logs/Xcode
rm -rf ~/Library/Logs/Developer

# 删除 CoreSimulator 目录
echo "删除 CoreSimulator 目录..."
if [ -d "$HOME/Library/Developer/CoreSimulator" ]; then
    rm -rf "$HOME/Library/Developer/CoreSimulator"
    echo "CoreSimulator 目录已删除"
fi

# 删除 Xcode 目录
echo "删除 Xcode 目录..."
if [ -d "$HOME/Library/Developer/Xcode" ]; then
    rm -rf "$HOME/Library/Developer/Xcode"
    echo "Xcode 目录已删除"
fi

# 清理系统缓存
echo "清理系统缓存..."
rm -rf /System/Library/Caches/com.apple.dt.Xcode
rm -rf /private/var/folders/*/com.apple.dt.Xcode

# 重置启动服务
echo "重置启动服务..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

echo "Xcode 删除完成！"
echo "备份位置：$BACKUP_DIR"