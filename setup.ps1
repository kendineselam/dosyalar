# ============================================
#  YENİ PC KURULUM SCRIPTİ
#  Admin (Yönetici) olarak çalıştırılmalı
# ============================================

Write-Host "===== KURULUM BAŞLIYOR =====" -ForegroundColor Cyan

# --------------------------------------------
# 1) CHROME KURULUMU
# --------------------------------------------
Write-Host "`n[1/5] Chrome kuruluyor..." -ForegroundColor Yellow

winget install --id Google.Chrome `
    --silent `
    --accept-package-agreements `
    --accept-source-agreements

# --------------------------------------------
# 2) 7-ZIP KURULUMU
# --------------------------------------------
Write-Host "`n[2/5] 7-Zip kuruluyor..." -ForegroundColor Yellow

winget install --id 7zip.7zip `
    --silent `
    --accept-package-agreements `
    --accept-source-agreements

# --------------------------------------------
# 3) THORIUM OTOMATİK KURULUM
# --------------------------------------------
Write-Host "`n[3/5] Thorium Browser kuruluyor..." -ForegroundColor Yellow

$thoriumApi = "https://api.github.com/repos/Alex313031/Thorium-Win/releases"
$thoriumTemp = "$env:TEMP\ThoriumSetup.exe"

try {

    Write-Host "  - Thorium release'leri kontrol ediliyor..." -ForegroundColor Cyan

    $headers = @{
        "User-Agent" = "Windows-Setup-Script"
    }

    $releases = Invoke-RestMethod `
        -Uri $thoriumApi `
        -Headers $headers `
        -ErrorAction Stop

    # Beta olmayan en güncel release'i bul
    $release = $releases |
        Where-Object {
            $_.prerelease -eq $false
        } |
        Select-Object -First 1

    if (-not $release) {

        throw "Kararlı Thorium release'i bulunamadı."
    }

    Write-Host "  - Sürüm bulundu: $($release.tag_name)" `
        -ForegroundColor Green

    # EXE installer'ı bul
    $asset = $release.assets |
        Where-Object {
            $_.name -match "\.exe$"
        } |
        Where-Object {
            $_.name -notmatch "chromedriver|portable|debug"
        } |
        Select-Object -First 1

    if (-not $asset) {

        throw "Thorium Windows installer EXE bulunamadı."
    }

    Write-Host "  - Installer: $($asset.name)" `
        -ForegroundColor Green

    Write-Host "  - Thorium indiriliyor..." `
        -ForegroundColor Cyan

    Invoke-WebRequest `
        -Uri $asset.browser_download_url `
        -OutFile $thoriumTemp `
        -UseBasicParsing `
        -ErrorAction Stop

    Write-Host "  - Thorium kuruluyor..." `
        -ForegroundColor Green

    # Installer'ı sessiz çalıştırmayı dene
    $thoriumProcess = Start-Process `
        -FilePath $thoriumTemp `
        -ArgumentList "/S" `
        -Wait `
        -PassThru

    if ($thoriumProcess.ExitCode -eq 0) {

        Write-Host "  - Thorium kurulumu tamamlandı." `
            -ForegroundColor Green
    }
    else {

        Write-Host "  - Thorium installer ExitCode: $($thoriumProcess.ExitCode)" `
            -ForegroundColor Yellow
    }

    Remove-Item `
        $thoriumTemp `
        -Force `
        -ErrorAction SilentlyContinue

}
catch {

    Write-Host "  - Thorium kurulumu başarısız!" `
        -ForegroundColor Red

    Write-Host "  - Hata: $($_.Exception.Message)" `
        -ForegroundColor DarkRed
}

# --------------------------------------------
# 4) GITHUB REPODAKİ .EXE DOSYALARI
# --------------------------------------------
Write-Host "`n[4/5] GitHub'daki programlar kuruluyor..." -ForegroundColor Yellow

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

    Remove-Item `
        $out `
        -Force `
        -ErrorAction SilentlyContinue
}

# --------------------------------------------
# 5) TAMPERMONKEY
#    CHROME + THORIUM
# --------------------------------------------
Write-Host "`n[5/5] Tampermonkey policy ayarlanıyor..." -ForegroundColor Yellow

$tampermonkeyId = "dhdgffkkebhmkfjojejmpbldmpobfkfo"
$updateUrl = "https://clients2.google.com/service/update2/crx"

# ============================================
# CHROME TAMPERMONKEY
# ============================================

$chromeRegPath = `
    "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"

if (-not (Test-Path $chromeRegPath)) {

    New-Item `
        -Path $chromeRegPath `
        -Force |
        Out-Null
}

Set-ItemProperty `
    -Path $chromeRegPath `
    -Name "1" `
    -Value "$tampermonkeyId;$updateUrl"

Write-Host "  ✓ Chrome -> Tampermonkey ayarlandı." `
    -ForegroundColor Green

# ============================================
# THORIUM TAMPERMONKEY
# ============================================

$thoriumRegPath = `
    "HKLM:\SOFTWARE\Policies\Chromium\ExtensionInstallForcelist"

if (-not (Test-Path $thoriumRegPath)) {

    New-Item `
        -Path $thoriumRegPath `
        -Force |
        Out-Null
}

Set-ItemProperty `
    -Path $thoriumRegPath `
    -Name "1" `
    -Value "$tampermonkeyId;$updateUrl"

Write-Host "  ✓ Thorium -> Tampermonkey ayarlandı." `
    -ForegroundColor Green

# ============================================
# KURULUM TAMAMLANDI
# ============================================

Write-Host ""
Write-Host "============================================" `
    -ForegroundColor Green

Write-Host "          KURULUM TAMAMLANDI" `
    -ForegroundColor Green

Write-Host "============================================" `
    -ForegroundColor Green

Write-Host ""
Write-Host "Kurulanlar:" -ForegroundColor Cyan
Write-Host "  ✓ Google Chrome"
Write-Host "  ✓ 7-Zip"
Write-Host "  ✓ Thorium"
Write-Host "  ✓ AnyDesk"
Write-Host "  ✓ AutoHotkey"
Write-Host "  ✓ Ihsan"
Write-Host "  ✓ PhotoScape"
Write-Host "  ✓ Brave"
Write-Host "  ✓ Tampermonkey -> Chrome"
Write-Host "  ✓ Tampermonkey -> Thorium"
Write-Host ""

# --------------------------------------------
# CHROME'U BAŞLAT
# --------------------------------------------

Start-Sleep -Seconds 3

Start-Process `
    "chrome.exe" `
    -ErrorAction SilentlyContinue

# --------------------------------------------
# THORIUM'U BAŞLAT
# --------------------------------------------

$thoriumPaths = @(
    "$env:LOCALAPPDATA\Thorium\Application\thorium.exe",
    "$env:PROGRAMFILES\Thorium\Application\thorium.exe",
    "${env:PROGRAMFILES(x86)}\Thorium\Application\thorium.exe"
)

foreach ($path in $thoriumPaths) {

    if (Test-Path $path) {

        Start-Process `
            -FilePath $path `
            -ErrorAction SilentlyContinue

        break
    }
}

Write-Host ""
Write-Host "Chrome ve Thorium başlatıldı." `
    -ForegroundColor Green