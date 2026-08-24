# ============================================
#  YENİ PC KURULUM SCRIPTI
#  Admin (Yönetici) olarak çalıştırılmalı
# ============================================

Write-Host "===== KURULUM BAŞLIYOR =====" -ForegroundColor Cyan

# --------------------------------------------
# 1) CHROME KURULUMU
# --------------------------------------------
Write-Host "`n[1/3] Chrome kuruluyor..." -ForegroundColor Yellow

winget install --id Google.Chrome `
    --silent `
    --accept-package-agreements `
    --accept-source-agreements

# --------------------------------------------
# 2) GITHUB REPODAKİ .EXE DOSYALARI
# --------------------------------------------
Write-Host "`n[2/3] GitHub'daki programlar kuruluyor..." -ForegroundColor Yellow

$repoRaw = "https://raw.githubusercontent.com/kendineselam/dosyalar/main"

$dosyalar = @{
    "anydesk.exe"                    = '--install "C:\Program Files (x86)\AnyDesk" --start-with-win --create-desktop-icon --silent'
    "autohotkey.exe"                 = "/S"
    "ihsan.exe"                      = $null
    "4565-PhotoScapeSetup_V3.7.exe"  = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /FORCECLOSEAPPLICATIONS"
    "BraveBrowserSetup-BRV002.exe"   = $null
}

foreach ($dosya in $dosyalar.Keys) {

    $url = "$repoRaw/$dosya"
    $out = "$env:TEMP\$dosya"

    Write-Host "`n  - İndiriliyor: $dosya" -ForegroundColor Cyan

    try {

        Invoke-WebRequest `
            -Uri $url `
            -OutFile $out `
            -ErrorAction Stop

    }
    catch {

        Write-Host "    Bulunamadı, atlanıyor: $dosya" `
            -ForegroundColor DarkGray

        continue
    }

    Write-Host "  - Kuruluyor: $dosya" -ForegroundColor Green

    $arg = $dosyalar[$dosya]

    if ($arg) {

        Start-Process `
            -FilePath $out `
            -ArgumentList $arg `
            -Wait

    }
    else {

        Start-Process `
            -FilePath $out `
            -Wait

    }

    Remove-Item $out -ErrorAction SilentlyContinue
}

# --------------------------------------------
# 3) TAMPERMONKEY - ZORUNLU KURULUM
# --------------------------------------------
Write-Host "`n[3/3] Tampermonkey policy ayarlanıyor..." -ForegroundColor Yellow

$tampermonkeyId = "dhdgffkkebhmkfjojejmpbldmpobfkfo"
$updateUrl = "https://clients2.google.com/service/update2/crx"

$regPath = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"

if (-not (Test-Path $regPath)) {

    New-Item `
        -Path $regPath `
        -Force |
        Out-Null
}

Set-ItemProperty `
    -Path $regPath `
    -Name "1" `
    -Value "$tampermonkeyId;$updateUrl"

Write-Host "`n===== KURULUM TAMAMLANDI =====" -ForegroundColor Green

Write-Host "Chrome'u açtığınızda Tampermonkey otomatik kurulacak."
Write-Host ""

# --------------------------------------------
# CHROME'U BAŞLAT
# --------------------------------------------

Start-Sleep -Seconds 2

Start-Process "chrome.exe" -ErrorAction SilentlyContinue