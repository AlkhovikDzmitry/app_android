# Генерация иконок приложения из исходного логотипа.
#
# Единственный источник — android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
# (432x432, белый фон, синий «горб» + надпись «БЕЛТЕХОСМОТР»). Логотип не
# перерисовывается: из него убирается белая подложка (белый -> прозрачный) и он
# вписывается в безопасную зону adaptive-иконки.
#
# Зачем вписывать, а не класть как есть: лаунчер вырезает из 108dp-канвы маску
# диаметром ~72dp. Логотип в исходнике занимает 406x108 px, то есть 101dp
# ширины — положив его без масштабирования, концы надписи отсекались бы маской.
#
# Запуск:  powershell -ExecutionPolicy Bypass -File tool\make_icons.ps1
# Требуется Windows + System.Drawing. Результат — обычные PNG, они хранятся в
# репозитории, поэтому на macOS/Mac-машине перегенерация не нужна.

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$res = Join-Path $root 'android\app\src\main\res'
$source = Join-Path $res 'mipmap-xxxhdpi\ic_launcher.png'

# --- Извлечение логотипа с прозрачным фоном -------------------------------
# Белый фон убирается по формуле un-premultiply над белой подложкой:
#   alpha = 255 - min(R,G,B);  C = 255 - (255 - observed) * 255 / alpha
# Так сохраняются полупрозрачные пиксели сглаживания на краях букв, а чистый
# синий #0000FF и красный #FF0000 остаются без изменений.
$src = [System.Drawing.Bitmap]::FromFile((Resolve-Path $source))
$W = $src.Width
$H = $src.Height

$logo = New-Object System.Drawing.Bitmap $W, $H, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$minX = $W; $maxX = -1; $minY = $H; $maxY = -1

for ($y = 0; $y -lt $H; $y++) {
    for ($x = 0; $x -lt $W; $x++) {
        $c = $src.GetPixel($x, $y)
        $m = [Math]::Min([Math]::Min($c.R, $c.G), $c.B)
        $a = 255 - $m
        if ($a -le 8) { continue }
        $r = [int](255 - (255 - $c.R) * 255 / $a)
        $g = [int](255 - (255 - $c.G) * 255 / $a)
        $b = [int](255 - (255 - $c.B) * 255 / $a)
        $logo.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $r, $g, $b))
        if ($x -lt $minX) { $minX = $x }
        if ($x -gt $maxX) { $maxX = $x }
        if ($y -lt $minY) { $minY = $y }
        if ($y -gt $maxY) { $maxY = $y }
    }
}
$src.Dispose()

$logoW = $maxX - $minX + 1
$logoH = $maxY - $minY + 1
Write-Host "logo bbox: $logoW x $logoH (ratio $([Math]::Round($logoW / $logoH, 3)))"

$crop = New-Object System.Drawing.Rectangle $minX, $minY, $logoW, $logoH
$logoCrop = $logo.Clone($crop, $logo.PixelFormat)
$logo.Dispose()

# --- Композиция канвы ----------------------------------------------------
# $logoFraction — доля ширины канвы, которую занимает логотип.
function New-IconCanvas([int]$px, [double]$logoFraction, [switch]$WhiteBackground, [switch]$BlackSilhouette) {
    $bmp = New-Object System.Drawing.Bitmap $px, $px, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    if ($WhiteBackground) {
        $g.Clear([System.Drawing.Color]::White)
    } else {
        $g.Clear([System.Drawing.Color]::Transparent)
    }

    $targetW = [int][Math]::Round($px * $logoFraction)
    $targetH = [int][Math]::Round($targetW * $logoCrop.Height / $logoCrop.Width)
    $x = [int](($px - $targetW) / 2)
    $y = [int](($px - $targetH) / 2)

    if ($BlackSilhouette) {
        # Монохромный слой: система сама перекрашивает его в цвет темы, важно
        # только silhouette, поэтому берём альф-канал логотипа целиком.
        $matrix = New-Object System.Drawing.Imaging.ColorMatrix
        $matrix.Matrix00 = 0; $matrix.Matrix11 = 0; $matrix.Matrix22 = 0
        $matrix.Matrix33 = 1
        $attrs = New-Object System.Drawing.Imaging.ImageAttributes
        $attrs.SetColorMatrix($matrix)
        $dest = New-Object System.Drawing.Rectangle $x, $y, $targetW, $targetH
        [void]$g.DrawImage($logoCrop, $dest, 0, 0, $logoCrop.Width, $logoCrop.Height,
            [System.Drawing.GraphicsUnit]::Pixel, $attrs)
        $attrs.Dispose()
    } else {
        $g.DrawImage($logoCrop, $x, $y, $targetW, $targetH)
    }

    $g.Dispose()
    return $bmp
}

function Test-Png([string]$path) {
    if (-not (Test-Path -LiteralPath $path)) { return $false }
    $fs = [System.IO.File]::OpenRead($path)
    try {
        if ($fs.Length -le 8) { return $false }
        $head = New-Object byte[] 8
        [void]$fs.Read($head, 0, 8)
    } finally { $fs.Close() }
    return $head[0] -eq 0x89 -and $head[1] -eq 0x50 -and $head[2] -eq 0x4E -and $head[3] -eq 0x47
}

function Save-Icon([System.Drawing.Bitmap]$bmp, [string]$path) {
    $dir = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    # GDI+ пишет PNG напрямую в цель: если файл в этот момент занят (антивирус,
    # индексатор, предыгрый запуск скрипта), на диске остаётся 0 байт, и
    # сборка потом падает с «file does not start with PNG signature». Поэтому
    # пишем во временный файл, проверяем сигнатуру и только потом подменяем
    # целевой. Повтор — на случай транзитрной блокировки.
    $tmp = "$path.tmp$PID"
    $lastError = $null
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force }
            $bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
            if (-not (Test-Png $tmp)) { throw 'written file has no PNG signature' }
            Move-Item -LiteralPath $tmp -Destination $path -Force
            $lastError = $null
            break
        } catch {
            $lastError = $_
            Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 200
        }
    }
    $bmp.Dispose()

    if ($lastError) {
        throw "Failed to write $path : $($lastError.Exception.Message)"
    }
    if (-not (Test-Png $path)) {
        throw "Final file is corrupt: $path"
    }
    $size = (Get-Item -LiteralPath $path).Length
    Write-Host "  -> $($path.Substring($root.Length + 1)) ($size B)"
}

# Adaptive-иконка: канва 108dp. Логотип — 58% ширины: полу-ширина 31.3dp и
# полу-высота 8.4dp дают радиус угла 32.5dp, то есть весь знак помещается в
# гарантированную зону 66dp и не срежется ни одной формой маски (круг, сквокл,
# капля). При 63% углы букв шли вплотную по краю видимого круга.
$fraction = 0.58
$densities = [ordered]@{ mdpi = 108; hdpi = 162; xhdpi = 216; xxhdpi = 324; xxxhdpi = 432 }

Write-Host "`nAndroid foreground:"
foreach ($d in $densities.GetEnumerator()) {
    Save-Icon (New-IconCanvas $d.Value $fraction) (Join-Path $res "drawable-$($d.Key)\ic_launcher_foreground.png")
}

Write-Host "`nAndroid monochrome:"
foreach ($d in $densities.GetEnumerator()) {
    Save-Icon (New-IconCanvas $d.Value $fraction -BlackSilhouette) (Join-Path $res "drawable-$($d.Key)\ic_launcher_monochrome.png")
}

# Легаси-иконки mipmap-*/ic_launcher.png не трогаем: они и есть исходный
# логотип на белом фоне, а скрипт читает из них источник.

# iOS: маска скругляет только углы квадрата, поэтому логотип крупнее — 78%.
Write-Host "`niOS AppIcon:"
$appIconDir = Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset'
$iosTargets = @(
    @('Icon-App-20x20@1x.png', 20), @('Icon-App-20x20@2x.png', 40), @('Icon-App-20x20@3x.png', 60),
    @('Icon-App-29x29@1x.png', 29), @('Icon-App-29x29@2x.png', 58), @('Icon-App-29x29@3x.png', 87),
    @('Icon-App-40x40@1x.png', 40), @('Icon-App-40x40@2x.png', 80), @('Icon-App-40x40@3x.png', 120),
    @('Icon-App-60x60@2x.png', 120), @('Icon-App-60x60@3x.png', 180),
    @('Icon-App-76x76@1x.png', 76), @('Icon-App-76x76@2x.png', 152),
    @('Icon-App-83.5x83.5@2x.png', 167), @('Icon-App-1024x1024@1x.png', 1024)
)
foreach ($t in $iosTargets) {
    Save-Icon (New-IconCanvas $t[1] 0.78 -WhiteBackground) (Join-Path $appIconDir $t[0])
}

# Web/PWA: обычный растр и maskable-вариант (у maskable своя безопасная зона).
Write-Host "`nWeb icons:"
$webDir = Join-Path $root 'web\icons'
Save-Icon (New-IconCanvas 192 0.78 -WhiteBackground) (Join-Path $webDir 'Icon-192.png')
Save-Icon (New-IconCanvas 512 0.78 -WhiteBackground) (Join-Path $webDir 'Icon-512.png')
Save-Icon (New-IconCanvas 192 $fraction -WhiteBackground) (Join-Path $webDir 'Icon-maskable-192.png')
Save-Icon (New-IconCanvas 512 $fraction -WhiteBackground) (Join-Path $webDir 'Icon-maskable-512.png')

$logoCrop.Dispose()
Write-Host "`nDone."
