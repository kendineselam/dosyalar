# ============================================
#  YENİ PC KURULUM SCRIPTI
#  Admin (Yönetici) olarak çalıştırılmalı
# ============================================

Write-Host "===== KURULUM BAŞLIYOR =====" -ForegroundColor Cyan

# --------------------------------------------
# 1) CHROME KURULUMU
# --------------------------------------------
Write-Host "`n[1/4] Chrome kuruluyor..." -ForegroundColor Yellow
winget install --id Google.Chrome --silent --accept-package-agreements --accept-source-agreements

# --------------------------------------------
# 2) WINGET İLE DİĞER PROGRAMLAR (programs.json)
#    programs.json dosyasını GitHub reponuza
#    "winget export -o programs.json" ile ekleyin
# --------------------------------------------
Write-Host "`n[2/4] Winget programları kuruluyor..." -ForegroundColor Yellow
$programsJsonUrl = "https://raw.githubusercontent.com/kendineselam/dosyalar/main/programs.json"
$programsJsonPath = "$env:TEMP\programs.json"

try {
    Invoke-WebRequest -Uri $programsJsonUrl -OutFile $programsJsonPath -ErrorAction Stop
    winget import -i $programsJsonPath --accept-package-agreements --accept-source-agreements
    Remove-Item $programsJsonPath
} catch {
    Write-Host "programs.json bulunamadı veya indirilemedi, bu adım atlandı." -ForegroundColor DarkGray
}

# --------------------------------------------
# 3) GITHUB REPODAKİ .EXE DOSYALARI
#    Her dosya için bilinen sessiz kurulum bayrağı
#    Bilinmeyenler normal (görünür) kurulum yapar
# --------------------------------------------
Write-Host "`n[3/4] Repo içindeki .exe dosyaları kuruluyor..." -ForegroundColor Yellow

$repoRaw = "https://raw.githubusercontent.com/kendineselam/dosyalar/main"

$dosyalar = @{
    "anydesk.exe"                   = '--install "C:\Program Files (x86)\AnyDesk" --start-with-win --create-desktop-icon --silent'
    "autohotkey.exe"                = "/S"
    "ihsan.exe"                     = $null
    "4565-PhotoScapeSetup_V3.7.exe" = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /FORCECLOSEAPPLICATIONS"
}

foreach ($dosya in $dosyalar.Keys) {
    $url = "$repoRaw/$dosya"
    $out = "$env:TEMP\$dosya"

    Write-Host "  - İndiriliyor: $dosya"
    try {
        Invoke-WebRequest -Uri $url -OutFile $out -ErrorAction Stop
    } catch {
        Write-Host "    Bulunamadı, atlanıyor: $dosya" -ForegroundColor DarkGray
        continue
    }

    Write-Host "  - Kuruluyor: $dosya"
    $arg = $dosyalar[$dosya]
    if ($arg) {
        Start-Process -FilePath $out -ArgumentList $arg -Wait
    } else {
        Start-Process -FilePath $out -Wait
    }

    Remove-Item $out -ErrorAction SilentlyContinue
}

# --------------------------------------------
# 4) TAMPERMONKEY - ZORUNLU KURULUM (Chrome Policy)
#    Chrome bir sonraki açılışta otomatik kurar
# --------------------------------------------
Write-Host "`n[4/4] Tampermonkey policy ile ayarlanıyor..." -ForegroundColor Yellow

$tampermonkeyId = "dhdgffkkebhmkfjojejmpbldmpobfkfo"
$updateUrl = "https://clients2.google.com/service/update2/crx"
$regPath = "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
Set-ItemProperty -Path $regPath -Name "1" -Value "$tampermonkeyId;$updateUrl"

Write-Host "`n===== KURULUM TAMAMLANDI =====" -ForegroundColor Green
Write-Host "Chrome'u açtığınızda Tampermonkey otomatik kurulacak."
Write-Host "Tampermonkey script yedeğinizi geri yüklemek için:"
Write-Host "  1) Chrome'da Tampermonkey ikonuna tıklayın"
Write-Host "  2) Dashboard > Utilities > Import from file/URL"
Write-Host ""

# Chrome'u başlat, Tampermonkey kurulumunu tetikle
Start-Sleep -Seconds 2
Start-Process "chrome.exe" -ErrorAction SilentlyContinue
