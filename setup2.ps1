# ============================================
# SETUP2 - BRAVE + TAMPERMONKEY
# Yönetici olarak çalıştırılmalı
# ============================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "     BRAVE + TAMPERMONKEY KURULUMU" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# --------------------------------------------
# 1) BRAVE KURULUMU
# --------------------------------------------

Write-Host "`n[1/2] Brave kuruluyor..." -ForegroundColor Yellow

try {

    winget install --id Brave.Brave `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Brave kurulumu başarılı." -ForegroundColor Green
    }
    else {
        Write-Host "Brave kurulumu başarısız! Kod: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }

}
catch {

    Write-Host "Brave kurulurken hata oluştu!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}


# --------------------------------------------
# 2) TAMPERMONKEY - BRAVE POLICY
# --------------------------------------------

Write-Host "`n[2/2] Tampermonkey Brave'e ekleniyor..." -ForegroundColor Yellow

$tampermonkeyId = "dhdgffkkebhmkfjojejmpbldmpobfkfo"
$updateUrl = "https://clients2.google.com/service/update2/crx"

$regPath = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave\ExtensionInstallForcelist"

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
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

Start-Sleep -Seconds 3

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

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "       KURULUM TAMAMLANDI" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "Brave kuruldu."
    Write-Host "Tampermonkey zorunlu kurulum policy'si aktif."
    Write-Host ""

}
else {

    Write-Host "Brave.exe bulunamadı!" -ForegroundColor Red
}