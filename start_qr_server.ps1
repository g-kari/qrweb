# QRコードスキャナー用サーバー起動スクリプト
# PowerShell版

Write-Host "=== QRコードスキャナー サーバー起動 ===" -ForegroundColor Green
Write-Host ""

# 現在のディレクトリを確認
$currentDir = Get-Location
Write-Host "現在のディレクトリ: $currentDir" -ForegroundColor Yellow

# PCのIPアドレスを取得
Write-Host ""
Write-Host "PCのIPアドレスを取得中..." -ForegroundColor Yellow
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" } | Select-Object -ExpandProperty IPAddress

Write-Host "利用可能なアクセスURL:" -ForegroundColor Green
Write-Host ""
Write-Host "【HTTPS (推奨 - スマホのカメラに必要)】" -ForegroundColor Green
foreach ($ip in $ipAddresses) {
    Write-Host "  https://$ip:8443" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "【HTTP (デスクトップ用)】" -ForegroundColor Yellow
foreach ($ip in $ipAddresses) {
    Write-Host "  http://$ip:8080" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "スマホのブラウザで上記のURLにアクセスしてください" -ForegroundColor Yellow
Write-Host "PCとスマホが同じWi-Fiネットワークに接続されている必要があります" -ForegroundColor Yellow
Write-Host ""

# HTTPSサーバーを起動
Write-Host "HTTPSサーバーを起動しています..." -ForegroundColor Green
Write-Host "（スマホのカメラアクセスにはHTTPSが必要です）" -ForegroundColor Yellow
Write-Host "終了するには Ctrl+C を押してください" -ForegroundColor Yellow
Write-Host ""

# まずHTTPSアクセス用のURLを表示
Write-Host "HTTPS URLでアクセスしてください:" -ForegroundColor Green
foreach ($ip in $ipAddresses) {
    Write-Host "  https://$ip:8443" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "証明書警告が表示された場合は「詳細設定」→「安全でないサイトに進む」を選択してください" -ForegroundColor Yellow
Write-Host ""

try {
    # Node.jsのhttp-serverでHTTPS対応サーバーを起動
    Write-Host "Node.js http-serverでHTTPSサーバーを起動します..." -ForegroundColor Green
    npx http-server -p 8443 -a 0.0.0.0 --cors -S
} catch {
    Write-Host "HTTPS起動に失敗しました。HTTPサーバーを試します..." -ForegroundColor Yellow
    
    try {
        # WSL Ubuntuでpython3サーバーを起動（HTTP）
        Write-Host "WSL UbuntuでHTTPサーバーを起動します..." -ForegroundColor Yellow
        Write-Host "注意: HTTPではスマホでカメラが動作しない可能性があります" -ForegroundColor Red
        wsl -d Ubuntu -e bash -c "cd /home/qrweb && python3 -m http.server 8080 --bind 0.0.0.0"
    } catch {
        Write-Host "エラー: WSL Ubuntuでサーバーを起動できませんでした" -ForegroundColor Red
        Write-Host "代替手段として、Windowsでサーバーを起動します..." -ForegroundColor Yellow
        
        # Pythonが利用可能か確認
        try {
            python --version | Out-Null
            python -m http.server 8080 --bind 0.0.0.0
        } catch {
            Write-Host "エラー: Pythonが見つかりません" -ForegroundColor Red
            Write-Host "手動でサーバーを起動してください:" -ForegroundColor Yellow
            Write-Host "  npx http-server -p 8443 -S" -ForegroundColor Cyan
            Write-Host "または" -ForegroundColor Yellow
            Write-Host "  python -m http.server 8080" -ForegroundColor Cyan
        }
    }
}
