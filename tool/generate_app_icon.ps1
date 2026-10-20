$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sourcePath = Join-Path $projectRoot 'assets\brand\app_icon.png'
$resRoot = Join-Path $projectRoot 'android\app\src\main\res'
$sourceImage = [System.Drawing.Image]::FromFile($sourcePath)

try {
    if ($sourceImage.Width -ne $sourceImage.Height) {
        throw "The app icon must be square. Found $($sourceImage.Width)x$($sourceImage.Height)."
    }

    $densityTargets = @(
        @{ Directory = 'mipmap-mdpi'; Launcher = 48; Foreground = 108 },
        @{ Directory = 'mipmap-hdpi'; Launcher = 72; Foreground = 162 },
        @{ Directory = 'mipmap-xhdpi'; Launcher = 96; Foreground = 216 },
        @{ Directory = 'mipmap-xxhdpi'; Launcher = 144; Foreground = 324 },
        @{ Directory = 'mipmap-xxxhdpi'; Launcher = 192; Foreground = 432 }
    )

    foreach ($target in $densityTargets) {
        $directory = Join-Path $resRoot $target.Directory
        New-Item -ItemType Directory -Force -Path $directory | Out-Null

        foreach ($entry in @(
            @{ Name = 'ic_launcher.png'; Size = $target.Launcher },
            @{ Name = 'ic_launcher_round.png'; Size = $target.Launcher },
            @{ Name = 'ic_launcher_foreground.png'; Size = $target.Foreground }
        )) {
            $bitmap = [System.Drawing.Bitmap]::new(
                $entry.Size,
                $entry.Size,
                [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
            )
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            try {
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
                $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $graphics.Clear([System.Drawing.Color]::Transparent)
                $graphics.DrawImage(
                    $sourceImage,
                    [System.Drawing.Rectangle]::new(0, 0, $entry.Size, $entry.Size),
                    0,
                    0,
                    $sourceImage.Width,
                    $sourceImage.Height,
                    [System.Drawing.GraphicsUnit]::Pixel
                )
                $destination = Join-Path $directory $entry.Name
                $bitmap.Save($destination, [System.Drawing.Imaging.ImageFormat]::Png)
            }
            finally {
                $graphics.Dispose()
                $bitmap.Dispose()
            }
        }
    }
}
finally {
    $sourceImage.Dispose()
}

Write-Host 'Generated launcher icons from assets/brand/app_icon.png.'
