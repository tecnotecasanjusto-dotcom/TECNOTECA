$ErrorActionPreference = 'Stop'
$originalPath = 'index.html'
$alternativePath = 'index (4).html'
$original = [IO.File]::ReadAllText($originalPath)
$alternative = [IO.File]::ReadAllText($alternativePath)

$originalSources = [regex]::Matches($original, '(?i)<img\b[^>]*\bsrc="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
$alternativeSources = [regex]::Matches($alternative, '(?i)<img\b[^>]*\bsrc="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
$newSources = $alternativeSources | Where-Object { $originalSources -notcontains $_ }

if ($newSources.Count -ne 3) {
    throw "Se esperaban 3 fuentes nuevas, se encontraron $($newSources.Count)."
}

$gridMarker = '    <div class="mt-9 grid grid-cols-2 md:grid-cols-4 gap-3">'
if (-not $original.Contains($gridMarker)) {
    throw 'No se encontró el grid de imágenes.'
}

$insert = ''
$imageTags = [regex]::Matches($alternative, '(?is)<a\b[^>]*class="[^"]*igtile[^"]*"[^>]*>\s*<img\b[^>]*>')
foreach ($tag in $imageTags) {
    $source = [regex]::Match($tag.Value, '(?i)\bsrc="([^"]+)"').Groups[1].Value
    if ($newSources -contains $source) {
        $href = [regex]::Match($tag.Value, '(?i)\bhref="([^"]+)"').Groups[1].Value
        $insert += "`n      <a href=`"$href`" target=`"_blank`" rel=`"noopener`" class=`"igtile glass card rounded-2xl aspect-square flex items-end p-4`"><img src=`"$source`"></a>"
    }
}

$updated = $original.Replace($gridMarker, $gridMarker + $insert, 1)
[IO.File]::WriteAllText($originalPath, $updated, [Text.UTF8Encoding]::new($false))
Write-Output "Insertadas $($newSources.Count) fotos nuevas en index.html."
