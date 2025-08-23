#!/bin/bash

# Flutter项目快速验证脚本
# 用于验证项目配置是否正确

echo "🚀 Flutter项目构建和运行验证"
echo "=================================="

# 检查Flutter环境
echo "📋 检查Flutter环境..."
flutter doctor

echo ""
echo "🔧 清理并重新获取依赖..."
flutter clean
flutter pub get

echo ""
echo "⚙️ 重新生成代码..."
dart run build_runner build

echo ""
echo "🎯 检查可用设备..."
flutter devices

echo ""
echo "📱 尝试构建测试..."

# 尝试iOS构建
echo "🍎 测试iOS构建..."
if flutter build ios --debug --no-codesign; then
    echo "✅ iOS构建成功！"
else
    echo "❌ iOS构建失败"
fi

echo ""
echo "🤖 测试Android构建..."
if flutter build apk --debug; then
    echo "✅ Android构建成功！"
else
    echo "❌ Android构建失败（可能需要配置Android SDK）"
fi

echo ""
echo "🌐 Web支持检查..."
if flutter build web; then
    echo "✅ Web构建成功！"
    echo "💡 可以使用 'flutter run -d chrome' 在浏览器中运行"
else
    echo "❌ Web构建失败"
fi

echo ""
echo "📊 构建验证完成！"
echo "=================================="
echo "📖 详细说明请查看 FLUTTER_BUILD_GUIDE.md"