# macOS-App-Langauge-switcher

## set_app_language.sh —— 批量 / 单独修改 macOS App 默认语言

## 用法示例:
### 批量(默认语言)
####   ./set_app_language.sh -d /Applications

### 批量(自定义语言)
####   ./set_app_language.sh -d / -l "zh-Hans-US zh-Hans en-US ja-JP"

### 单个 App(默认语言)
####   ./set_app_language.sh -a /Applications/Safari.app

### 单个 App(自定义语言)
####   ./set_app_language.sh -a "/Applications/微信.app" -l "zh-Hans-US zh-Hans en-US ja-JP"
