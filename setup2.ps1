# ============================================
#  YENİ PC - BRAVE + TAMPERMONKEY KURULUMU
#  Admin (Yönetici) olarak çalıştırılmalı
# ============================================

Write-Host "===== BRAVE KURULUMU BAŞLIYOR =====" -ForegroundColor Cyan

# --------------------------------------------
# 1) BRAVE KURULUMU
# --------------------------------------------

Write-Host "`n[1/2] Brave indiriliyor ve kuruluyor..." -ForegroundColor Yellow

$repoRaw = "https://raw.githubusercontent.com/kendineselam/dosyalar/main"
$dosya = "BraveBrowserSetup-BRV002.exe"
$url = "$repoRaw/$dosya"
$out = "$env:TEMP\$dosya"

try {

    Invoke-WebRequest `
        -Uri $url `
        -OutFile $out `
        -ErrorAction Stop

    Write-Host "Brave indirildi." -ForegroundColor Green

}
catch {

    Write-Host "Brave indirilemedi!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit
}

Write-Host "Brave kurulumu başlatılıyor..." -ForegroundColor Yellow

Start-Process `
    -FilePath $out `
    -Wait

Remove-Item $out -ErrorAction SilentlyContinue

Write-Host "Brave kurulumu tamamlandı." -ForegroundColor Green


# --------------------------------------------
# 2) TAMPERMONKEY - BRAVE POLICY
# --------------------------------------------

Write-Host "`n[2/2] Brave için Tampermonkey ayarlanıyor..." -ForegroundColor Yellow

$tampermonkeyId = "dhdgffkkebhmkfjojejmpbldmpobfkfo"
$updateUrl = "https://clients2.google.com/service/update2/crx"

$regPath = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\ExtensionInstallForcelist"

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

Write-Host "Tampermonkey policy ayarlandı." -ForegroundColor Green


# --------------------------------------------
# BRAVE'İ BAŞLAT
# --------------------------------------------

Write-Host "`nBrave başlatılıyor..." -ForegroundColor Cyan

Start-Sleep -Seconds 2

$bravePaths = @(
    "${env:ProgramFiles}\BraveSoftware\Brave-Browser\Application\brave.exe",
    "${env:ProgramFiles(x86)}\BraveSoftware\Brave-Browser\Application\brave.exe",
    "${env:LOCALAPPDATA}\BraveSoftware\Brave-Browser\Application\brave.exe"
)

$bravePath = $bravePaths |
    Where-Object { Test-Path $_ } |
    Select-Object -First 1

if ($bravePath) {

    Start-Process $bravePath

    Write-Host "`n===== KURULUM TAMAMLANDI =====" -ForegroundColor Green
    Write-Host "Brave açıldı."
    Write-Host "Tampermonkey zorunlu olarak kurulacak." -ForegroundColor Green

}
else {

    Write-Host "Brave.exe bulunamadı!" -ForegroundColor Red
}