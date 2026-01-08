# Simple Job Creation Test

$adminEmail = "admin@test.com"
$adminPassword = "admin123"

Write-Host "Testing Job Creation API..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Login
Write-Host "1. Logging in as admin..." -ForegroundColor Yellow
$loginBody = @{
    email = $adminEmail
    password = $adminPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/auth/login" -Method POST -Body $loginBody -ContentType 'application/json' -UseBasicParsing
    $loginData = $loginResponse.Content | ConvertFrom-Json
    $token = $loginData.token
    Write-Host "   [OK] Login successful - Role: $($loginData.user.role)" -ForegroundColor Green
} catch {
    Write-Host "   [FAIL] Login failed" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Response: $responseBody" -ForegroundColor Red
        $reader.Close()
    }
    exit 1
}

Write-Host ""

# Step 2: Create Job
Write-Host "2. Creating a test job..." -ForegroundColor Yellow
$jobData = @{
    title = "Senior Full Stack Developer"
    description = "We are looking for an experienced Full Stack Developer to join our team."
    skills = "React,Node.js,PostgreSQL,TypeScript"
    experience = "5+ years"
    application_deadline = "2026-02-15"
} | ConvertTo-Json

try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $createResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/jobs" -Method POST -Body $jobData -Headers $headers -UseBasicParsing
    $createdJob = $createResponse.Content | ConvertFrom-Json
    
    Write-Host "   [OK] Job created successfully" -ForegroundColor Green
    Write-Host "   Job ID: $($createdJob.job.id)" -ForegroundColor Gray
    Write-Host "   Title: $($createdJob.job.title)" -ForegroundColor Gray
    Write-Host "   Skills: $($createdJob.job.skills)" -ForegroundColor Gray
} catch {
    Write-Host "   [FAIL] Job creation failed" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Response: $responseBody" -ForegroundColor Red
        $reader.Close()
    }
    exit 1
}

Write-Host ""
Write-Host "[SUCCESS] Job creation API is working!" -ForegroundColor Green
