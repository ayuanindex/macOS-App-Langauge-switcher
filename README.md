# macOS-App-Langauge-switcher
单个 App 语言切换，或指定目录下所有 App 语言切换
#===============================================================
# set_app_language.sh —— 批量 / 单独修改 macOS App 默认语言
#
# 用法示例:
#   ./set_app_language.sh -d /Applications               # 批量(默认语言)
#   ./set_app_language.sh -d / -l "en-US en ja-JP"       # 批量(自定义语言)
#   ./set_app_language.sh -a /Applications/Safari.app    # 单个 App
#   ./set_app_language.sh -a "/Applications/微信.app" -l "zh-Hans"
#===============================================================
