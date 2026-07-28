$root = $PSScriptRoot
$port = 5173
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root on http://localhost:$port/"

$mime = @{
  ".html" = "text/html; charset=utf-8"; ".css" = "text/css"; ".js" = "application/javascript"
  ".svg" = "image/svg+xml"; ".png" = "image/png"; ".jpg" = "image/jpeg"
  ".jpeg" = "image/jpeg"; ".ico" = "image/x-icon"; ".json" = "application/json"
}

while ($listener.IsListening) {
  try {
    $context = $listener.GetContext()
  } catch {
    continue
  }

  try {
    $req = $context.Request
    $res = $context.Response
    $res.KeepAlive = $false
    $isHead = $req.HttpMethod -eq "HEAD"

    $path = [System.Uri]::UnescapeDataString($req.Url.LocalPath)
    if ($path -eq "/") { $path = "/index.html" }
    $filePath = Join-Path $root ($path.TrimStart("/"))
    $fullRoot = (Resolve-Path $root).Path
    $isInsideRoot = $false
    if (Test-Path $filePath -PathType Leaf) {
      $resolvedFile = (Resolve-Path $filePath).Path
      $isInsideRoot = $resolvedFile.StartsWith($fullRoot, [System.StringComparison]::OrdinalIgnoreCase)
    }

    if ($isInsideRoot) {
      $ext = [System.IO.Path]::GetExtension($filePath)
      $contentType = $mime[$ext]
      if (-not $contentType) { $contentType = "application/octet-stream" }
      $bytes = [System.IO.File]::ReadAllBytes($resolvedFile)
      $res.StatusCode = 200
      $res.ContentType = $contentType
      $res.ContentLength64 = [int64]$bytes.Length
      if (-not $isHead) {
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
      }
    } else {
      $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
      $res.StatusCode = 404
      $res.ContentType = "text/plain; charset=utf-8"
      $res.ContentLength64 = [int64]$msg.Length
      if (-not $isHead) {
        $res.OutputStream.Write($msg, 0, $msg.Length)
      }
    }
  } catch {
    Write-Host "Request error [$($req.HttpMethod) $($req.Url.LocalPath)]: $($_.Exception.Message)"
  } finally {
    try { $context.Response.OutputStream.Close() } catch {}
    try { $context.Response.Close() } catch {}
  }
}
