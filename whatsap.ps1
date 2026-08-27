$repoRaw = "https://raw.githubusercontent.com/kendineselam/dosyalar/main"

# --------------------------------------------
# 6) WHATSAPP EMBEDDED (WebView2 + AutoHotkey)
# --------------------------------------------
Write-Host "`n[6/6] WhatsApp Embedded kuruluyor..." -ForegroundColor Yellow

$wpZipUrl  = "$repoRaw/wp.zip"
$wpZipTemp = "$env:TEMP\wp.zip"
$wpDest    = "C:\WP"
$ahkPath   = "$wpDest\WhatsAppEmbedded.ahk"

try {

    Write-Host "  - wp.zip indiriliyor..." -ForegroundColor Cyan

    Invoke-WebRequest `
        -Uri $wpZipUrl `
        -OutFile $wpZipTemp `
        -ErrorAction Stop

    Write-Host "  - C:\WP'ye çıkartılıyor..." -ForegroundColor Cyan

    if (-not (Test-Path $wpDest)) {
        New-Item -Path $wpDest -ItemType Directory -Force | Out-Null
    }

    Expand-Archive `
        -Path $wpZipTemp `
        -DestinationPath $wpDest `
        -Force `
        -ErrorAction Stop

    Remove-Item $wpZipTemp -Force -ErrorAction SilentlyContinue

    Write-Host "  - Çıkartma tamamlandı." -ForegroundColor Green

    # AutoHotkey.exe'nin tam yolunu bul (winget ile kurulan tipik konum,
    # bulunamazsa PATH üzerinden dener)
    $ahkExeCandidates = @(
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:ProgramFiles\AutoHotkey\AutoHotkey.exe",
        "${env:ProgramFiles(x86)}\AutoHotkey\AutoHotkey.exe"
    )
    $ahkExe = $ahkExeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $ahkExe) {
        $ahkExe = (Get-Command AutoHotkey.exe -ErrorAction SilentlyContinue).Source
    }
    if (-not $ahkExe) {
        $ahkExe = (Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue).Source
    }

    if (-not $ahkExe) {
        throw "AutoHotkey.exe bulunamadı, önce AutoHotkey kurulmalı."
    }

    Write-Host "  - AutoHotkey bulundu: $ahkExe" -ForegroundColor Green

    # ---- GÖREV ZAMANLAYICI: oturum açılışında çalışsın ----
    $taskName = "WhatsAppEmbedded"

    $action = New-ScheduledTaskAction `
        -Execute $ahkExe `
        -Argument "`"$ahkPath`"" `
        -WorkingDirectory $wpDest

    $trigger = New-ScheduledTaskTrigger -AtLogOn

    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -ExecutionTimeLimit (New-TimeSpan -Seconds 0)   # süresiz çalışabilsin

    $principal = New-ScheduledTaskPrincipal `
        -UserId "$env:USERDOMAIN\$env:USERNAME" `
        -LogonType Interactive `
        -RunLevel Limited

    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }

    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal | Out-Null

    Write-Host "  ✓ Görev Zamanlayıcı görevi oluşturuldu: $taskName" -ForegroundColor Green

    # ---- STARTUP KLASÖRÜNE KISAYOL EKLE ----
    # (Görev Zamanlayıcı zaten oturum açılışında çalıştırıyor; Startup
    #  kısayolu ek bir güvence/yedek olarak ekleniyor)
    $startupFolder = [Environment]::GetFolderPath("Startup")
    $shortcutPath  = Join-Path $startupFolder "WhatsAppEmbedded.lnk"

    $wsh = New-Object -ComObject WScript.Shell
    $shortcut = $wsh.CreateShortcut($shortcutPath)
    $shortcut.TargetPath       = $ahkExe
    $shortcut.Arguments        = "`"$ahkPath`""
    $shortcut.WorkingDirectory = $wpDest
    $iconPath = "$wpDest\WhatsApp.ico"
    if (Test-Path $iconPath) {
        $shortcut.IconLocation = $iconPath
    }
    $shortcut.Save()

    Write-Host "  ✓ Startup kısayolu eklendi: $shortcutPath" -ForegroundColor Green

    # ---- ŞİMDİ DE BAŞLAT ----
    Start-Process -FilePath $ahkExe -ArgumentList "`"$ahkPath`"" -WorkingDirectory $wpDest

    Write-Host "  ✓ WhatsApp Embedded başlatıldı." -ForegroundColor Green

}
catch {

    Write-Host "  - WhatsApp Embedded kurulumu başarısız!" -ForegroundColor Red
    Write-Host "  - Hata: $($_.Exception.Message)" -ForegroundColor DarkRed
}
