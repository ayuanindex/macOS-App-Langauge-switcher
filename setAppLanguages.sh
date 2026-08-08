#!/bin/bash
#===============================================================
# set_app_language.sh —— 批量 / 单独修改 macOS App 默认语言
#
# 用法示例:
#   ./set_app_language.sh -d /Applications               # 批量(默认语言)
#   ./set_app_language.sh -d / -l "en-US en ja-JP"       # 批量(自定义语言)
#   ./set_app_language.sh -a /Applications/Safari.app    # 单个 App
#   ./set_app_language.sh -a "/Applications/微信.app" -l "zh-Hans"
#===============================================================
DEFAULT_LANGS="zh-Hans-US zh-Hans zh-CN"
APPLIST_FILE="$HOME/Desktop/applist.txt"
ERROR_FILE="$HOME/Desktop/errorset.txt"

usage() {
    echo "用法:"
    echo "  $0 -d <目录>   [-l \"语言1 语言2 ...\"]"
    echo "  $0 -a <App路径> [-l \"语言1 语言2 ...\"]"
    echo "  $0 -h"
    echo "默认语言: $DEFAULT_LANGS"
}

find_apps() {
    local dir="$1"
    sudo find "$dir" -name "*.app" -print 2>&1 | fgrep -v "Operation not permitted" | fgrep -v "No such file or directory" | fgrep -v "Not a directory" | grep -v "/System/Volumes/Data/"
}

set_app_language() {
    local app_path="$1"
    local record_error="$2"
    shift 2
    local langs=("$@")
    local result=""
    local fallback_path=""
    local result2=""

    result=$(defaults write -app "$app_path" AppleLanguages -array "${langs[@]}" 2>&1)

    if [ -z "$result" ]; then
        echo "✅ 设置成功          : $app_path"
        return 0
    fi

    if echo "$result" | grep -q "does not exist"; then
        fallback_path=$(echo "$result" | sed -n 's/.*Domain \(.*\) does not exist.*/\1/p' | head -n 1)
        fallback_path="${fallback_path/#\~/$HOME}"
        if [ -n "$fallback_path" ]; then
            result2=$(defaults write "$fallback_path" AppleLanguages -array "${langs[@]}" 2>&1)
            if [ -z "$result2" ]; then
                echo "✅ 设置成功(容器)    : $app_path"
                return 0
            fi
            result="$result2"
        fi
    fi

    echo "❌ 设置失败          : $app_path"
    echo "   └─ $result"
    if [ "$record_error" = "yes" ]; then
        echo "App   : $app_path" >> "$ERROR_FILE"
        echo "Error : $result" >> "$ERROR_FILE"
        echo "----------------------------------------" >> "$ERROR_FILE"
    fi
    return 1
}

batch_set() {
    local dir="$1"
    shift
    local langs=("$@")

    if [ ! -d "$dir" ]; then
        echo "错误: 目录不存在: $dir"
        exit 1
    fi

    echo "==> 正在检索 $dir 下的所有 .app ..."
    find_apps "$dir" > "$APPLIST_FILE"

    local total=0
    total=$(grep -c . "$APPLIST_FILE")
    echo "==> 共找到 $total 个 App，列表已保存到: $APPLIST_FILE"
    if [ "$total" -eq 0 ]; then
        echo "未找到任何 App，退出。"
        exit 0
    fi

    : > "$ERROR_FILE"

    local i=0
    local ok=0
    local fail=0
    while IFS= read -r app_path; do
        if [ -z "$app_path" ]; then
            continue
        fi
        i=$((i + 1))
        echo "[$i/$total]"
        if set_app_language "$app_path" "yes" "${langs[@]}"; then
            ok=$((ok + 1))
        else
            fail=$((fail + 1))
        fi
    done < "$APPLIST_FILE"

    echo ""
    echo "========== 完成 =========="
    echo "总计: $total  成功: $ok  失败: $fail"
    if [ "$fail" -eq 0 ]; then
        rm -f "$ERROR_FILE"
    else
        echo "错误详情: $ERROR_FILE"
    fi
}

single_set() {
    local app_path="$1"
    shift
    local langs=("$@")
    if [ ! -d "$app_path" ]; then
        echo "错误: App 路径不存在: $app_path"
        exit 1
    fi
    echo "==> 正在设置: $app_path"
    set_app_language "$app_path" "no" "${langs[@]}"
}

SEARCH_DIR=""
APP_PATH=""
CUSTOM_LANGS=""

while getopts ":d:a:l:h" opt; do
    case "$opt" in
        d) SEARCH_DIR="$OPTARG" ;;
        a) APP_PATH="$OPTARG" ;;
        l) CUSTOM_LANGS="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -n "$SEARCH_DIR" ] && [ -n "$APP_PATH" ]; then
    echo "错误: -d 和 -a 不能同时使用"
    exit 1
fi
if [ -z "$SEARCH_DIR" ] && [ -z "$APP_PATH" ]; then
    usage
    exit 1
fi

LANGS=()
if [ -n "$CUSTOM_LANGS" ]; then
    read -r -a LANGS <<< "$CUSTOM_LANGS"
else
    read -r -a LANGS <<< "$DEFAULT_LANGS"
fi
if [ ${#LANGS[@]} -eq 0 ]; then
    read -r -a LANGS <<< "$DEFAULT_LANGS"
fi

echo "==> 语言选项: ${LANGS[*]}"

if [ -n "$SEARCH_DIR" ]; then
    batch_set "$SEARCH_DIR" "${LANGS[@]}"
else
    single_set "$APP_PATH" "${LANGS[@]}"
fi
