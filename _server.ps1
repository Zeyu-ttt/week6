$root = $PSScriptRoot
$port = 8000
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root at http://localhost:$port/  (Ctrl+C to stop)"
try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $url = $ctx.Request.Url.LocalPath
    if ($url -eq "/") { $url = "/index.html" }
    $path = Join-Path $root ($url.TrimStart("/"))
    if (Test-Path -PathType Leaf $path) {
      $bytes = [System.IO.File]::ReadAllBytes($path)
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
      $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $url")
      $ctx.Response.OutputStream.Write($msg, 0, $msg.Length)
    }
    $ctx.Response.Close()
  }
} finally {
  $listener.Stop()
}
