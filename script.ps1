param(
    [Parameter(Mandatory=$true)]
    [int]$port
)
$folderPath = (Get-Location).Path
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:$port/")
$listener.Start()
Write-Host "HTTP server is listening on port $port. Press Ctrl+C to stop."
try {
    while ($true) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        $localPath = (Join-Path $folderPath $request.RawUrl.Substring(1))
        if (Test-Path $localPath) {
            $fileBytes = [System.IO.File]::ReadAllBytes($localPath)
            $response.ContentType = 'application/octet-stream'
            $response.ContentLength64 = $fileBytes.Length
            $response.OutputStream.Write($fileBytes, 0, $fileBytes.Length)
            $response.Close()
            Write-Host "Served file: $localPath"
        } else {
            $response.StatusCode = 404
            $response.Close()
            Write-Host "Not found: $localPath"
} }
} finally {
    $listener.Stop()
}