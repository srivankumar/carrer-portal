# Test Resume Download
$resumeKey = "resumes/5013aeb2-6f73-47fc-8287-c4da3c0fc46e_53883a75-54b1-4e19-bc35-272eacc46a0a_1767894782366.pdf"

Write-Host "Testing Resume Download..." -ForegroundColor Cyan
Write-Host "Key: $resumeKey" -ForegroundColor Gray
Write-Host ""

# Login
Write-Host "1. Logging in..." -ForegroundColor Yellow
$loginBody = '{"email":"testadmin@job-portal.com","password":"Admin@123"}'
$loginResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/auth/login" -Method POST -Body $loginBody -ContentType 'application/json' -UseBasicParsing
$token = ($loginResponse.Content | ConvertFrom-Json).token
Write-Host "   [OK] Logged in" -ForegroundColor Green

# Test download
Write-Host ""
Write-Host "2. Requesting download URL..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    $downloadResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/applications/download/$resumeKey" -Method GET -Headers $headers -UseBasicParsing
    $result = $downloadResponse.Content | ConvertFrom-Json
    
    Write-Host "   [SUCCESS] Got download URL!" -ForegroundColor Green
    Write-Host ""
    Write-Host "   Full URL:" -ForegroundColor Cyan
    Write-Host "   $($result.url)" -ForegroundColor White
    Write-Host ""
    Write-Host "   Opening in browser..." -ForegroundColor Yellow
    Start-Process $result.url
    
} catch {
    Write-Host "   [FAIL] Error occurred" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host ""
        Write-Host "   Response Body:" -ForegroundColor Yellow
        Write-Host "   $responseBody" -ForegroundColor Gray
        $reader.Close()
    }
}
