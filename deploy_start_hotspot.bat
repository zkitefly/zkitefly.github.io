@echo off
rem deploy_start_hotspot.bat
rem 需要以管理员权限运行。脚本会在 C:\ProgramData\StartMobileHotspot 下写入 start-hotspot.ps1，
rem 为当前用户创建登录时运行的计划任务，并可立即验证一次启动。

:: 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 本脚本需要以 管理员 身份运行。
    echo 请右键“以管理员身份运行”此 BAT 文件或在管理员 PowerShell/命令提示符下执行。
    pause
    exit /b 1
)

set "INSTALL_DIR=C:\ProgramData\StartMobileHotspot"
set "PS_PATH=%INSTALL_DIR%\start-hotspot.ps1"
setlocal

echo 正在创建目录 %INSTALL_DIR% ...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo 正在写入 PowerShell 启动脚本到 %PS_PATH% ...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Set-Content -Path '%PS_PATH%' -Value @'
Add-Type -AssemblyName System.Windows.Forms

function Show-Info($text, $title = '移动热点') {
    [System.Windows.Forms.MessageBox]::Show($text, $title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
}

try {
    $drivers = netsh wlan show drivers 2>&1
    if ($drivers -match 'Hosted network supported\s*:\s*Yes') {
        $start = netsh wlan start hostednetwork 2>&1
        if ($start -match 'The hosted network started') {
            Show-Info '移动热点已启用（hostednetwork 已启动）。'
            exit 0
        } else {
            Show-Info ('尝试启用移动热点失败：`n' + ($start -join \"`n\"))
            exit 2
        }
    } else {
        Show-Info '当前驱动或硬件不支持 hosted network，无法通过 netsh 启用移动热点。请检查无线网卡驱动或使用系统设置手动启用移动热点。'
        exit 3
    }
}
catch {
    Show-Info ('启动移动热点过程中发生异常：`n' + $_.Exception.Message)
    exit 4
}
'@ -Encoding UTF8 -Force;"

if %errorlevel% neq 0 (
    echo 写入 PowerShell 文件失败。请检查权限与 PowerShell 可用性。
    pause
    exit /b 2
)

echo.
:ASK_CONFIG
set /p REPLY_CONFIG=是否现在为 hostednetwork 配置 SSID 与 密码？(Y/N)：
if /i "%REPLY_CONFIG%"=="Y" goto CONFIGURE_SSID
if /i "%REPLY_CONFIG%"=="N" goto CREATE_TASK
echo 请输入 Y 或 N.
goto ASK_CONFIG

:CONFIGURE_SSID
set /p HOTSSID=请输入 SSID（热点名称）：
rem 读取密码并校验至少 8 位
setlocal EnableDelayedExpansion
:INPUT_KEY
set /p HOTKEY=请输入 密码（至少 8 位）：
if "!HOTKEY!"=="" (
    echo 密码不能为空。
    goto INPUT_KEY
)
rem 检查第8个字符是否存在（索引7），若不存在则长度 <8
if "!HOTKEY:~7,1!"=="" (
    echo 密码长度不足 8 位，请重试。
    goto INPUT_KEY
)
endlocal & set "HOTKEY=%HOTKEY%"

echo 正在配置 hostednetwork...
netsh wlan set hostednetwork mode=allow ssid="%HOTSSID%" key="%HOTKEY%"
echo 配置结果如下：
netsh wlan show hostednetwork
echo.

:CREATE_TASK
set "TASK_NAME=StartMobileHotspot_OnLogon_%USERNAME%"
rem 构造任务动作，注意对引号转义
set "POW_ACTION=powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Normal -File \"%PS_PATH%\""

echo 正在创建计划任务：%TASK_NAME% （ONLOGON）...
schtasks /Create /SC ONLOGON /TN "%TASK_NAME%" /TR "%POW_ACTION%" /RL HIGHEST /F
if %errorlevel% equ 0 (
    echo 计划任务创建成功。
) else (
    echo 警告：创建计划任务可能失败（错误码 %errorlevel%）。若失败，请手动创建计划任务，运行动作为：
    echo %POW_ACTION%
)

echo.
:ASK_RUN_NOW
set /p RUNNOW=是否立即尝试运行一次以验证启动移动热点？(Y/N)：
if /i "%RUNNOW%"=="Y" goto RUN_NOW
if /i "%RUNNOW%"=="N" goto FINISH_PROMPT
echo 请输入 Y 或 N.
goto ASK_RUN_NOW

:RUN_NOW
echo 正在运行启动脚本（会弹出提示框）...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_PATH%"
echo 已执行一次尝试。请查看弹窗或系统通知以确认结果。
echo.

:FINISH_PROMPT
:CONFIRM
set /p CONFIRM=部署是否已完成且验证通过？(Y/N)：
if /i "%CONFIRM%"=="Y" (
    echo 已确认：部署成功。
    pause
    exit /b 0
)
if /i "%CONFIRM%"=="N" (
    echo 未确认部署成功。请检查：
    echo  - 无线网卡驱动是否支持 Hosted network：运行 `netsh wlan show drivers` 并查看 "Hosted network supported"；
    echo  - 是否已以管理员身份运行本脚本；
    echo  - 查看 %PS_PATH% 中的错误提示（脚本会弹窗显示错误信息）。
    pause
    exit /b 0
)
echo 请输入 Y 或 N.
goto CONFIRM