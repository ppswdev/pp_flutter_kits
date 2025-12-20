#!/bin/bash

# Docker 完全卸载脚本 for macOS
# 安全版本 - 仅清理 Docker 相关文件，不影响其他开发环境
# 版本: 2.0

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 全局变量
DRY_RUN=false
VERBOSE=false
FILES_TO_REMOVE=()
FILES_REMOVED=0
FILES_SKIPPED=0

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

log_preview() {
    echo -e "${CYAN}[PREVIEW]${NC} $1"
}

# 检查是否为 root 用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "请不要使用 root 用户运行此脚本"
        exit 1
    fi
}

# 转换为小写（兼容 macOS bash 3.2）
to_lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# 严格的路径验证
validate_docker_path() {
    local path="$1"
    
    # 禁止包含 .. 的路径（防止目录遍历）
    if [[ "$path" == *".."* ]]; then
        return 1
    fi
    
    # 必须是明确的 Docker 相关路径
    local docker_patterns=(
        "*docker*"
        "*Docker*"
        "com.docker.*"
        "group.com.docker*"
    )
    
    local is_docker_path=false
    for pattern in "${docker_patterns[@]}"; do
        if [[ "$path" == $pattern ]]; then
            is_docker_path=true
            break
        fi
    done
    
    # 额外检查：路径中必须包含 docker 关键字（不区分大小写）
    local path_lower=$(to_lower "$path")
    if [[ "$path_lower" != *"docker"* ]]; then
        return 1
    fi
    
    # 禁止删除的关键系统路径
    local forbidden_paths=(
        "/System"
        "/usr"
        "/bin"
        "/sbin"
        "/etc"
        "/var"
        "/opt/homebrew"
        "/usr/local"
    )
    
    for forbidden in "${forbidden_paths[@]}"; do
        if [[ "$path" == "$forbidden" ]] || [[ "$path" == "$forbidden/"* ]]; then
            # 允许 /usr/local/bin/docker 这样的具体文件
            if [[ "$path" != "$forbidden/bin/docker"* ]] && \
               [[ "$path" != "$forbidden/lib/docker"* ]]; then
                return 1
            fi
        fi
    done
    
    return 0
}

# 安全检查：验证路径是否只包含 Docker 相关内容
safe_remove() {
    local path="$1"
    local description="$2"
    
    if ! validate_docker_path "$path"; then
        log_error "安全警告：跳过可疑路径: $path"
        ((FILES_SKIPPED++))
        return 1
    fi
    
    if [[ -e "$path" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log_preview "将删除: $description"
            log_debug "  路径: $path"
            FILES_TO_REMOVE+=("$path")
        else
            log_info "删除: $description"
            log_debug "  路径: $path"
            rm -rf "$path"
            ((FILES_REMOVED++))
        fi
        return 0
    else
        log_debug "不存在，跳过: $path"
        return 1
    fi
}

# 安全删除文件（需要 sudo）
safe_remove_sudo() {
    local path="$1"
    local description="$2"
    
    if ! validate_docker_path "$path"; then
        log_error "安全警告：跳过可疑路径: $path"
        ((FILES_SKIPPED++))
        return 1
    fi
    
    if [[ -f "$path" ]] || [[ -L "$path" ]] || [[ -d "$path" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log_preview "将删除（需要sudo）: $description"
            log_debug "  路径: $path"
            FILES_TO_REMOVE+=("$path [需要sudo]")
        else
            log_info "删除: $description"
            log_debug "  路径: $path"
            sudo rm -rf "$path"
            ((FILES_REMOVED++))
        fi
        return 0
    else
        log_debug "不存在，跳过: $path"
        return 1
    fi
}

# 检查 Docker 是否正在使用
check_docker_usage() {
    log_info "检查 Docker 使用情况..."
    
    local in_use=false
    local usage_info=()
    
    # 检查是否有运行的容器
    if command -v docker &> /dev/null; then
        local containers=$(docker ps -q 2>/dev/null || true)
        if [[ -n "$containers" ]]; then
            usage_info+=("有运行中的容器: $(echo $containers | wc -w | tr -d ' ') 个")
            in_use=true
        fi
    fi
    
    # 检查是否有挂载的卷
    if command -v docker &> /dev/null; then
        local volumes=$(docker volume ls -q 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$volumes" -gt 0 ]]; then
            usage_info+=("有 Docker 卷: $volumes 个")
        fi
    fi
    
    # 检查是否有自定义网络
    if command -v docker &> /dev/null; then
        local networks=$(docker network ls -q 2>/dev/null | grep -v "bridge\|host\|none" | wc -l | tr -d ' ')
        if [[ "$networks" -gt 0 ]]; then
            usage_info+=("有自定义网络: $networks 个")
        fi
    fi
    
    if [[ "$in_use" == true ]]; then
        log_warn "检测到 Docker 正在使用中："
        for info in "${usage_info[@]}"; do
            echo "  - $info"
        done
        log_warn "这些数据将在卸载时被删除"
        echo ""
        read -p "是否继续？(yes/no): " continue_choice
        if [[ $continue_choice != "yes" ]]; then
            log_info "操作已取消"
            exit 0
        fi
    else
        log_info "未检测到正在使用的 Docker 资源"
    fi
}

# 确认操作
confirm_uninstall() {
    log_warn "此脚本将完全卸载 Docker 及其所有相关数据"
    log_warn "包括："
    echo "  - Docker Desktop 应用程序"
    echo "  - 所有容器、镜像和卷"
    echo "  - 所有配置文件和缓存"
    echo "  - Docker 命令行工具"
    echo ""
    log_info "安全保证："
    echo "  ✓ 只删除 Docker 相关文件"
    echo "  ✓ 不会影响 Homebrew、Node.js、Python 等其他开发工具"
    echo "  ✓ 不会删除系统关键文件"
    echo ""
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "预览模式：将只显示要删除的文件，不会实际删除"
        echo ""
    fi
    
    read -p "确定要继续吗？(yes/no): " confirm
    if [[ $confirm != "yes" ]]; then
        log_info "操作已取消"
        exit 0
    fi
}

# 停止 Docker 进程
stop_docker() {
    log_info "正在停止 Docker 进程..."
    
    # 检查 Docker 是否安装
    if ! command -v docker &> /dev/null && [[ ! -d "/Applications/Docker.app" ]]; then
        log_warn "未检测到 Docker，可能已经卸载"
        return 0
    fi
    
    # 停止所有运行的容器（如果 docker 命令可用）
    if command -v docker &> /dev/null && [[ "$DRY_RUN" != true ]]; then
        log_info "停止所有运行的容器..."
        running_containers=$(docker ps -q 2>/dev/null || true)
        if [[ -n "$running_containers" ]]; then
            docker stop $running_containers 2>/dev/null || true
        fi
    fi
    
    # 退出 Docker Desktop（如果正在运行）
    log_info "退出 Docker Desktop..."
    if pgrep -f "Docker Desktop" > /dev/null; then
        if [[ "$DRY_RUN" != true ]]; then
            osascript -e 'quit app "Docker"' 2>/dev/null || true
            sleep 3
        else
            log_preview "将退出 Docker Desktop 应用"
        fi
    fi
    
    # 强制杀死 Docker 相关进程（仅 Docker 相关）
    if [[ "$DRY_RUN" != true ]]; then
        log_info "强制停止 Docker 相关进程..."
        pkill -f "Docker Desktop" 2>/dev/null || true
        pkill -f "com.docker.backend" 2>/dev/null || true
        pkill -f "com.docker.driver" 2>/dev/null || true
        pkill -f "docker.*daemon" 2>/dev/null || true
        sleep 2
    else
        log_preview "将停止 Docker 相关进程"
    fi
    
    log_info "Docker 进程已停止"
}

# 删除 Docker Desktop 应用
remove_docker_app() {
    log_info "删除 Docker Desktop 应用程序..."
    safe_remove "/Applications/Docker.app" "Docker Desktop 应用程序"
}

# 删除用户数据目录（仅 Docker 相关）
remove_user_data() {
    log_info "删除用户数据目录..."
    
    local dirs=(
        "$HOME/Library/Containers/com.docker.docker"
        "$HOME/Library/Application Support/Docker Desktop"
        "$HOME/Library/Group Containers/group.com.docker"
        "$HOME/Library/HTTPStorages/com.docker.docker"
        "$HOME/Library/Preferences/com.docker.docker.plist"
        "$HOME/Library/Saved Application State/com.electron.docker-frontend.savedState"
        "$HOME/Library/Logs/Docker Desktop"
        "$HOME/.docker"
    )
    
    for dir in "${dirs[@]}"; do
        safe_remove "$dir" "Docker 用户数据"
    done
}

# 删除命令行工具（仅 Docker 相关）
remove_cli_tools() {
    log_info "删除 Docker 命令行工具..."
    
    local tools=(
        "/usr/local/bin/docker"
        "/usr/local/bin/docker-compose"
        "/usr/local/bin/docker-credential-desktop"
        "/usr/local/bin/docker-credential-ecr-login"
        "/usr/local/bin/docker-credential-osxkeychain"
        "/usr/local/bin/docker-credential-helper"
        "/usr/local/bin/docker-machine"
        "/usr/local/bin/docker-compose-v1"
        "/usr/local/bin/docker-compose-v2"
        "/usr/local/bin/docker-credential"
    )
    
    for tool in "${tools[@]}"; do
        if [[ -L "$tool" ]]; then
            link_target=$(readlink "$tool" 2>/dev/null || true)
            local link_target_lower=$(to_lower "$link_target")
            if [[ "$link_target_lower" == *"docker"* ]]; then
                safe_remove_sudo "$tool" "Docker 命令行工具"
            fi
        elif [[ -f "$tool" ]]; then
            local tool_lower=$(to_lower "$tool")
            if [[ "$tool_lower" == *"docker"* ]]; then
                safe_remove_sudo "$tool" "Docker 命令行工具"
            fi
        fi
    done
    
    # 检查是否有 Docker 专用的 lib 目录
    if [[ -d "/usr/local/lib/docker" ]]; then
        safe_remove_sudo "/usr/local/lib/docker" "Docker 库目录"
    fi
}

# 删除系统扩展
remove_system_extensions() {
    log_info "检查 Docker 系统扩展..."
    
    if command -v systemextensionsctl &> /dev/null; then
        local extensions=$(systemextensionsctl list 2>/dev/null | grep -iE "docker|com\.docker" || true)
        
        if [[ -n "$extensions" ]]; then
            log_warn "发现 Docker 系统扩展："
            echo "$extensions"
            log_warn "系统扩展需要手动在以下位置禁用："
            log_warn "  系统设置 > 隐私与安全性 > 系统扩展"
            log_warn "或者重启后系统会自动提示处理"
        else
            log_info "未发现 Docker 系统扩展"
        fi
    fi
}

# 清理 LaunchAgents 和 LaunchDaemons
remove_launch_agents() {
    log_info "清理 Docker 相关的 LaunchAgents 和 LaunchDaemons..."
    
    local agents=(
        "$HOME/Library/LaunchAgents/com.docker.vmnetd.plist"
    )
    
    for agent in "${agents[@]}"; do
        if [[ -f "$agent" ]]; then
            if [[ "$DRY_RUN" != true ]]; then
                launchctl unload "$agent" 2>/dev/null || true
            fi
            safe_remove "$agent" "Docker LaunchAgent"
        fi
    done
    
    local system_agents=(
        "/Library/LaunchAgents/com.docker.vmnetd.plist"
        "/Library/LaunchDaemons/com.docker.vmnetd.plist"
    )
    
    for agent in "${system_agents[@]}"; do
        if [[ -f "$agent" ]]; then
            if [[ "$DRY_RUN" != true ]]; then
                launchctl unload "$agent" 2>/dev/null || true
            fi
            safe_remove_sudo "$agent" "Docker LaunchDaemon"
        fi
    done
}

# 清理缓存
clean_cache() {
    log_info "清理 Docker 缓存..."
    
    local caches=(
        "$HOME/Library/Caches/com.docker.docker"
        "$HOME/Library/Caches/com.electron.docker-frontend"
    )
    
    for cache in "${caches[@]}"; do
        safe_remove "$cache" "Docker 缓存"
    done
}

# 清理其他可能的 Docker 相关文件
remove_other_files() {
    log_info "清理其他 Docker 相关文件..."
    
    local configs=(
        "$HOME/.docker/config.json"
        "$HOME/.docker/daemon.json"
    )
    
    for config in "${configs[@]}"; do
        if [[ -f "$config" ]]; then
            safe_remove "$config" "Docker 配置文件"
        fi
    done
    
    if [[ -d "$HOME/Library/Preferences/com.docker" ]]; then
        safe_remove "$HOME/Library/Preferences/com.docker" "Docker 偏好设置目录"
    fi
}

# 清理环境变量（提示用户）
clean_environment_variables() {
    log_info "检查环境变量配置..."
    
    local shell_configs=(
        "$HOME/.zshrc"
        "$HOME/.bash_profile"
        "$HOME/.bashrc"
        "$HOME/.profile"
    )
    
    local found_docker_vars=false
    
    for config in "${shell_configs[@]}"; do
        if [[ -f "$config" ]]; then
            if grep -q -i "docker" "$config" 2>/dev/null; then
                log_warn "在 $config 中发现可能的 Docker 相关配置"
                found_docker_vars=true
            fi
        fi
    done
    
    if [[ "$found_docker_vars" == true ]]; then
        log_warn "请手动检查并删除以下文件中的 Docker 相关环境变量："
        for config in "${shell_configs[@]}"; do
            if [[ -f "$config" ]] && grep -q -i "docker" "$config" 2>/dev/null; then
                echo "  - $config"
            fi
        done
    else
        log_info "未发现 Docker 相关的环境变量配置"
    fi
}

# 验证卸载
verify_uninstall() {
    log_info "验证卸载结果..."
    
    local found=false
    local issues=()
    
    if [[ -d "/Applications/Docker.app" ]]; then
        issues+=("Docker.app 仍然存在")
        found=true
    fi
    
    if command -v docker &> /dev/null; then
        docker_path=$(which docker)
        local docker_path_lower=$(to_lower "$docker_path")
        if [[ "$docker_path_lower" == *"docker"* ]]; then
            issues+=("docker 命令仍然存在: $docker_path")
            found=true
        fi
    fi
    
    if [[ -d "$HOME/Library/Containers/com.docker.docker" ]]; then
        issues+=("Docker 数据目录仍然存在")
        found=true
    fi
    
    if [[ "$found" == false ]]; then
        log_info "✓ Docker 已完全卸载"
        log_info "✓ 未发现残留文件"
        log_info "✓ 删除了 $FILES_REMOVED 个文件/目录"
        if [[ $FILES_SKIPPED -gt 0 ]]; then
            log_warn "跳过了 $FILES_SKIPPED 个可疑路径（安全保护）"
        fi
    else
        log_warn "发现以下残留："
        for issue in "${issues[@]}"; do
            log_warn "  - $issue"
        done
    fi
}

# 显示预览结果
show_preview() {
    if [[ "$DRY_RUN" == true ]] && [[ ${#FILES_TO_REMOVE[@]} -gt 0 ]]; then
        echo ""
        log_info "预览结果："
        log_info "将删除以下 ${#FILES_TO_REMOVE[@]} 个文件/目录："
        for file in "${FILES_TO_REMOVE[@]}"; do
            echo "  - $file"
        done
        echo ""
        log_info "这是预览模式，没有实际删除任何文件"
        log_info "要实际执行删除，请运行: $0 (不带 --dry-run 参数)"
    fi
}

# 显示保护说明
show_protection_info() {
    log_info "脚本安全保护措施："
    echo "  ✓ 只删除包含 'docker' 的文件和目录"
    echo "  ✓ 严格的路径验证，防止误删系统文件"
    echo "  ✓ 不会删除 /usr/local/bin 目录本身"
    echo "  ✓ 不会影响 Homebrew、Node.js、Python 等其他开发工具"
    echo "  ✓ 不会删除系统关键文件和目录"
    echo ""
}

# 显示帮助信息
show_help() {
    echo "Docker 完全卸载脚本 for macOS"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --dry-run      预览模式，只显示要删除的文件，不实际删除"
    echo "  --verbose, -v  显示详细调试信息"
    echo "  --help, -h     显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0             执行卸载"
    echo "  $0 --dry-run   预览要删除的文件"
    echo "  $0 --verbose   显示详细日志"
    echo ""
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# 主函数
main() {
    echo "=========================================="
    echo "  Docker 完全卸载脚本 for macOS"
    echo "  安全版本 - 仅清理 Docker"
    echo "  版本: 2.0"
    echo "=========================================="
    echo ""
    
    parse_args "$@"
    check_root
    show_protection_info
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "运行在预览模式"
        echo ""
    fi
    
    check_docker_usage
    confirm_uninstall
    
    echo ""
    log_info "开始卸载 Docker..."
    echo ""
    
    stop_docker
    remove_docker_app
    remove_user_data
    remove_cli_tools
    remove_launch_agents
    clean_cache
    remove_other_files
    remove_system_extensions
    clean_environment_variables
    
    echo ""
    verify_uninstall
    show_preview
    
    echo ""
    if [[ "$DRY_RUN" != true ]]; then
        log_info "卸载完成！"
        log_info "✓ 您的其他开发环境（Homebrew、Node.js、Python 等）未受影响"
        log_warn "建议重启系统以确保所有进程已完全停止"
    fi
    echo ""
}

# 运行主函数
main "$@"

