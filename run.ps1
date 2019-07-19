$start = [DateTime]::Now

docker run --rm -p 8000:8000 -d aminueza/cassinoapi:v1.0.0

$stop = [DateTime]::Now
$elapsed = $stop - $start

Write-Host
Write-Host $elapsed
Write-Host
