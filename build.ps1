$start = [DateTime]::Now

docker build --tag aminueza/cassinoapi:v1.0.0 .

$stop = [DateTime]::Now
$elapsed = $stop - $start

Write-Host
Write-Host $elapsed
Write-Host
