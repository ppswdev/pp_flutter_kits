#!/bin/bash
# 自动化打包IPA，上传符号表到FirebaseCrashlytics，上传IPA到AppStore
# Author: 肖品
# Date: 2025-06-10
# 前提：一定要配置好Firebase Crashlytics，并配置好ios/Runner/GoogleService-Info.plist
# 1.存储位置: flutter工程目录/scripts/build_upload_ios.sh
# 2.授予权限：chmod +x scripts/build_upload_ios.sh
# 3.执行命令：./scripts/build_upload_ios.sh -s 2.2.0.87 -a appleid123@gmail.com -p aaaa-bbbb-cccc-dddd
#           ./scripts/build_upload_ios.sh -s 1.0.9.43 -a 苹果开发者账号 -p @keychain:ryh_upload_pwd
#   可以把密码放到：@keychain钥匙串中

# 定义清理函数
cleanup() {
  echo "⚠️ 收到中断信号,正在清理..."
  # 删除临时文件和中间产物
  rm -rf build/ios/ipa/* 2>/dev/null
  rm -rf "$SYMBOL_DIR" 2>/dev/null
  echo "✅ 清理完成,脚本已终止"
  exit 1
}

# 捕获中断信号
trap cleanup INT TERM

set -e

# 默认值
SYMBOLS_SUB_DIR="ios"
APPLE_ID=""
APP_PASSWORD=""

# 解析命令行参数
while getopts "s:a:p:" opt; do
  case $opt in
    s) SYMBOLS_SUB_DIR="$OPTARG";;
    a) APPLE_ID="$OPTARG";;
    p) APP_PASSWORD="$OPTARG";;
    \?) echo "无效的选项 -$OPTARG" >&2; exit 1;;
  esac
done

# 校验参数
if [[ -z "$SYMBOLS_SUB_DIR" ]]; then
  echo "⚠️ 未提供 symbols子目录，使用默认值: ios"
fi

# 检查 -a 和 -p 参数是否同时存在或同时不存在
if [[ -n "$APPLE_ID" && -z "$APP_PASSWORD" ]] || [[ -z "$APPLE_ID" && -n "$APP_PASSWORD" ]]; then
  echo "❌ -a 和 -p 参数必须同时提供"
  exit 1
fi

# 切换到脚本所在目录的上级（项目根目录）
cd "$(dirname "$0")/.."

SYMBOL_DIR="symbols/$SYMBOLS_SUB_DIR"
SYMBOL_FILE="$SYMBOL_DIR/app.ios-arm64.symbols"
SYMBOL_dSYM_FILE="$SYMBOL_DIR/Runner.app.dSYM"
SOURCE_dSYM_FILE="build/ios/archive/Runner.xcarchive/dSYMs/Runner.app.dSYM"

echo "🔥构建路径"
echo "符号表目录: $SYMBOL_DIR"
echo "Flutter符号表：$SYMBOL_FILE"
echo "dSYM符号表：$SYMBOL_dSYM_FILE"

echo "开始构建代码混淆的IPA..."
flutter build ipa --obfuscate --split-debug-info=$SYMBOL_DIR || { echo "❌ IPA构建失败"; cleanup; }
echo "IPA构建完成！"

# 检查源dSYM文件是否存在
if [[ ! -d "$SOURCE_dSYM_FILE" ]]; then
  echo "❌ 源dSYM文件未生成：$SOURCE_dSYM_FILE"
  cleanup
fi

# 复制dSYM文件到符号目录
echo "正在复制dSYM文件到符号目录..."
cp -R "$SOURCE_dSYM_FILE" "$SYMBOL_DIR" || { echo "❌ dSYM文件复制失败"; cleanup; }
echo "dSYM文件复制完成$SYMBOL_dSYM_FILE"

echo "准备上传符号表到FirebaseCrashlytics..."
echo "正在检测相关文件是否存在..."

# 检查符号文件是否存在
if [[ ! -f "$SYMBOL_FILE" ]]; then
  echo "❌ 符号文件未生成：$SYMBOL_FILE"
  cleanup
fi

# 检查 upload-symbols 脚本是否存在
if [[ ! -f "ios/Pods/FirebaseCrashlytics/upload-symbols" ]]; then
  echo "❌ 找不到 upload-symbols 脚本"
  cleanup
fi

# 检查 GoogleService-Info.plist 是否存在
if [[ ! -f "ios/Runner/GoogleService-Info.plist" ]]; then
  echo "❌ 找不到 GoogleService-Info.plist 文件"
  cleanup
fi

# 检查符号文件目录是否存在
if [[ ! -d "symbols/$SYMBOLS_DIR" ]]; then
  echo "❌ 找不到符号文件目录: symbols/$SYMBOLS_DIR"
  cleanup
fi

echo "正在上传符号文件到 Firebase Crashlytics..."
./ios/Pods/FirebaseCrashlytics/upload-symbols \
 -gsp ios/Runner/GoogleService-Info.plist \
 -p ios $SYMBOL_FILE || { echo "❌ Flutter符号表上传失败"; cleanup; }

echo "✅ $SYMBOL_FILE 符号表上传完成"

./ios/Pods/FirebaseCrashlytics/upload-symbols \
 -gsp ios/Runner/GoogleService-Info.plist \
 -p ios $SYMBOL_dSYM_FILE || { echo "❌ dSYM符号表上传失败"; cleanup; }

echo "✅ $SYMBOL_dSYM_FILE 符号表上传完成"

# 检查是否提供了 Apple ID 和密码
if [[ -n "$APPLE_ID" && -n "$APP_PASSWORD" ]]; then
  echo "准备上传到 App Store..."
  
  # 检查 xcrun 命令是否可用
  if ! command -v xcrun &> /dev/null; then
    echo "❌ 找不到 xcrun 命令"
    cleanup
  fi
  
  echo "正在上传 IPA 到 App Store..."
  xcrun altool --upload-app -f build/ios/ipa/*.ipa \
    -t ios \
    -u "$APPLE_ID" \
    -p "$APP_PASSWORD" \
    || { echo "❌ IPA上传失败"; cleanup; }
  #  --show-progress || { echo "❌ IPA上传失败"; cleanup; }
  
  if [ $? -eq 0 ]; then
    echo "✅ IPA 成功上传到AppStore！"
  else
    echo "❌ IPA 上传失败"
    cleanup
  fi
else
  echo "⚠️ 未提供 Apple ID 和密码，跳过上传到 App Store"
fi

# 移除中断信号捕获
trap - INT TERM
echo "✅ 所有任务已完成"