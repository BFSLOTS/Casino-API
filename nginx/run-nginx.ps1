$start = [DateTime]::Now

docker run --rm -p 80:80 -d aminueza/nginx:v1.0.0

$stop = [DateTime]::Now
$elapsed = $stop - $start

Write-Host
Write-Host $elapsed
Write-Host
