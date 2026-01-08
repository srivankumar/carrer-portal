# Test Resume Download Endpoint

Write-Host "Testing Resume Download API..." -ForegroundColor Cyan
Write-Host ""

# Login first
$loginBody = '{"email":"testadmin@job-portal.com","password":"Admin@123"}'
$loginResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/auth/login" -Method POST -Body $loginBody -ContentType 'application/json' -UseBasicParsing
$token = ($loginResponse.Content | ConvertFrom-Json).token

Write-Host "[OK] Logged in successfully" -ForegroundColor Green
Write-Host ""

# Get applications to find a resume key
Write-Host "Fetching applications..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $appsResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/applications/all" -Method GET -Headers $headers -UseBasicParsing
    $apps = ($appsResponse.Content | ConvertFrom-Json).applications
    
    if ($apps.Count -eq 0) {
        Write-Host "[INFO] No applications found. Please apply for a job first." -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "[OK] Found $($apps.Count) application(s)" -ForegroundColor Green
    
    # Get the first application's resume key
    $firstApp = $apps[0]
    $resumeKey = $firstApp.resume_url.key
    
    Write-Host ""
    Write-Host "Testing download for resume: $resumeKey" -ForegroundColor Cyan
    Write-Host ""
    
    # Test the download endpoint
    $downloadResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/applications/download/$([System.Web.HttpUtility]::UrlEncode($resumeKey))" -Method GET -Headers $headers -UseBasicParsing
    $downloadData = $downloadResponse.Content | ConvertFrom-Json
    
    Write-Host "[SUCCESS] Download URL generated!" -ForegroundColor Green
    Write-Host "URL: $($downloadData.url.Substring(0, 100))..." -ForegroundColor Gray
    Write-Host ""
    Write-Host "The download endpoint is working correctly!" -ForegroundColor Green
    
} catch {
    Write-Host "[FAIL] Error occurred" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Red
        $reader.Close()
    }
}
