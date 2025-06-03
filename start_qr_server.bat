@echo off
echo === QRコードスキャナー サーバー起動 ===
echo.

rem 現在のディレクトリを確認
echo 現在のディレクトリ: %CD%

echo.
echo PCのIPアドレスを取得中...
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr "IPv4"') do (
    set "IP=%%i"
    setlocal enabledelayedexpansion
    set "IP=!IP: =!"
    echo   http://!IP!:8080
    endlocal
)

echo.
echo スマホのブラウザで上記のURLにアクセスしてください
echo PCとスマホが同じWi-Fiネットワークに接続されている必要があります
echo.

echo サーバーを起動しています...
echo 終了するには Ctrl+C を押してください
echo.

rem WSL Ubuntuでサーバーを起動
wsl -d Ubuntu -e bash -c "cd /home/qrweb && python3 -m http.server 8080 --bind 0.0.0.0"

rem エラーが発生した場合の代替手段
if errorlevel 1 (
    echo.
    echo エラー: WSL Ubuntuでサーバーを起動できませんでした
    echo 代替手段として、Windowsでサーバーを起動します...
    
    python --version >nul 2>&1
    if errorlevel 1 (
        echo エラー: Pythonが見つかりません
        echo Node.jsのhttp-serverを試します...
        npx http-server -p 8080 -a 0.0.0.0 --cors
    ) else (
        python -m http.server 8080 --bind 0.0.0.0
    )
)

pause
