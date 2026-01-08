# Test Job Creation Validation

Write-Host "Testing Job Creation Validation..." -ForegroundColor Cyan
Write-Host ""

# Login first
$loginBody = '{"email":"testadmin@job-portal.com","password":"Admin@123"}' 
$loginResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/auth/login" -Method POST -Body $loginBody -ContentType 'application/json' -UseBasicParsing
$token = ($loginResponse.Content | ConvertFrom-Json).token

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Test 1: Missing title
Write-Host "Test 1: Missing title field..." -ForegroundColor Yellow
try {
    $body = '{"description":"Test","skills":"React","experience":"2 years","application_deadline":"2026-02-15"}'
    Invoke-WebRequest -Uri "http://localhost:3001/api/jobs" -Method POST -Body $body -Headers $headers -UseBasicParsing -ErrorAction Stop | Out-Null
    Write-Host "   [FAIL] Should have rejected missing title" -ForegroundColor Red
} catch {
    Write-Host "   [OK] Correctly rejected - Missing title" -ForegroundColor Green
}

# Test 2: Missing skills
Write-Host "Test 2: Missing skills field..." -ForegroundColor Yellow
try {
    $body = '{"title":"Test Job","description":"Test","experience":"2 years","application_deadline":"2026-02-15"}'
    Invoke-WebRequest -Uri "http://localhost:3001/api/jobs" -Method POST -Body $body -Headers $headers -UseBasicParsing -ErrorAction Stop | Out-Null
    Write-Host "   [FAIL] Should have rejected missing skills" -ForegroundColor Red
} catch {
    Write-Host "   [OK] Correctly rejected - Missing skills" -ForegroundColor Green
}

# Test 3: Valid job creation
Write-Host "Test 3: Valid job creation..." -ForegroundColor Yellow
try {
    $body = '{"title":"Backend Developer","description":"Node.js expert needed","skills":"Node.js,MongoDB","experience":"3 years","application_deadline":"2026-03-01"}'
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/jobs" -Method POST -Body $body -Headers $headers -UseBasicParsing
    $job = ($response.Content | ConvertFrom-Json).job
    Write-Host "   [OK] Job created - ID: $($job.id)" -ForegroundColor Green
} catch {
    Write-Host "   [FAIL] Valid job was rejected" -ForegroundColor Red
}

Write-Host ""
Write-Host "[COMPLETE] Validation tests finished" -ForegroundColor Cyan
