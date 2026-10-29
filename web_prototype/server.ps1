param (
    [int]$Port = 8080
)

$Listener = New-Object System.Net.HttpListener
$Prefix = "http://localhost:$Port/"
$Listener.Prefixes.Add($Prefix)

try {
    $Listener.Start()
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host " LabLens AI - Interactive Prototype Server Running" -ForegroundColor Green
    Write-Host " URL: $Prefix" -ForegroundColor Yellow
    Write-Host " Open in browser: http://localhost:$Port" -ForegroundColor White
    Write-Host "==========================================================" -ForegroundColor Cyan
} catch {
    Write-Error "Failed to bind to port $Port. Error: $_"
    exit 1
}

$CurrentDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DocPath = Join-Path (Split-Path -Parent $CurrentDir) "Documentation\MIDTERM_PHASE3_SUBMISSION.md"

while ($Listener.IsListening) {
    try {
        $Context = $Listener.GetContext()
        $Request = $Context.Request
        $Response = $Context.Response

        $RawUrl = $Request.RawUrl.Split('?')[0]

        if ($RawUrl -eq "/" -or $RawUrl -eq "/index.html") {
            $FilePath = Join-Path $CurrentDir "index.html"
            $ContentType = "text/html; charset=utf-8"
        } elseif ($RawUrl -eq "/MIDTERM_PHASE3_SUBMISSION.md") {
            $FilePath = $DocPath
            $ContentType = "text/markdown; charset=utf-8"
        } else {
            $FilePath = Join-Path $CurrentDir ($RawUrl.TrimStart('/'))
            $Ext = [System.IO.Path]::GetExtension($FilePath).ToLower()
            $ContentType = switch ($Ext) {
                ".html" { "text/html; charset=utf-8" }
                ".css"  { "text/css; charset=utf-8" }
                ".js"   { "application/javascript; charset=utf-8" }
                ".json" { "application/json; charset=utf-8" }
                ".png"  { "image/png" }
                ".jpg"  { "image/jpeg" }
                ".svg"  { "image/svg+xml" }
                ".md"   { "text/markdown; charset=utf-8" }
                Default { "text/plain; charset=utf-8" }
            }
        }

        if (Test-Path $FilePath) {
            $Bytes = [System.IO.File]::ReadAllBytes($FilePath)
            $Response.ContentType = $ContentType
            $Response.ContentLength64 = $Bytes.Length
            $Response.StatusCode = 200
            $Response.OutputStream.Write($Bytes, 0, $Bytes.Length)
        } else {
            $NotFound = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $Response.StatusCode = 404
            $Response.ContentType = "text/plain"
            $Response.ContentLength64 = $NotFound.Length
            $Response.OutputStream.Write($NotFound, 0, $NotFound.Length)
        }
        $Response.OutputStream.Close()
    } catch {
        # Continue loop on aborted client requests
    }
}
