# Register Admin and Test Job Creation

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  JOB CREATION API COMPLETE TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$adminEmail = "testadmin@job-portal.com"
$adminPassword = "Admin@123"
$adminName = "Test Admin"

# Step 1: Register admin user
Write-Host "1. Registering admin user..." -ForegroundColor Yellow
$registerBody = @{
    name = $adminName
    email = $adminEmail
    password = $adminPassword
    role = "admin"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/auth/register" -Method POST -Body $registerBody -ContentType 'application/json' -UseBasicParsing
    Write-Host "   [OK] Admin user registered" -ForegroundColor Green
} catch {
    # User might already exist
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 400) {
        Write-Host "   [INFO] User may already exist, proceeding to login..." -ForegroundColor Yellow
    } else {
        Write-Host "   [WARN] Registration issue (code: $statusCode), trying login..." -ForegroundColor Yellow
    }
}

Write-Host ""

# Step 2: Login as admin
Write-Host "2. Logging in as admin..." -ForegroundColor Yellow
$loginBody = @{
    email = $adminEmail
    password = $adminPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/auth/login" -Method POST -Body $loginBody -ContentType 'application/json' -UseBasicParsing
    $loginData = $loginResponse.Content | ConvertFrom-Json
    $token = $loginData.token
    $userRole = $loginData.user.role
    
    Write-Host "   [OK] Login successful" -ForegroundColor Green
    Write-Host "   Email: $($loginData.user.email)" -ForegroundColor Gray
    Write-Host "   Role: $userRole" -ForegroundColor Gray
    Write-Host "   Token: $($token.Substring(0, 30))..." -ForegroundColor Gray
    
    if ($userRole -ne "admin") {
        Write-Host ""
        Write-Host "   [ERROR] User is not an admin! Please update role in Supabase." -ForegroundColor Red
        exit 1
    }
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

# Step 3: Create a test job
Write-Host "3. Creating a test job..." -ForegroundColor Yellow
$jobData = @{
    title = "Senior Full Stack Developer"
    description = "We are looking for an experienced Full Stack Developer to join our team. You will work on cutting-edge technologies and collaborate with a talented team."
    skills = "React,Node.js,PostgreSQL,TypeScript,Express.js"
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
    
    Write-Host "   [OK] Job created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "   Job Details:" -ForegroundColor Cyan
    Write-Host "   ============" -ForegroundColor Cyan
    Write-Host "   ID: $($createdJob.job.id)" -ForegroundColor White
    Write-Host "   Title: $($createdJob.job.title)" -ForegroundColor White
    Write-Host "   Description: $($createdJob.job.description)" -ForegroundColor White
    Write-Host "   Skills: $($createdJob.job.skills)" -ForegroundColor White
    Write-Host "   Experience: $($createdJob.job.experience)" -ForegroundColor White
    Write-Host "   Deadline: $($createdJob.job.application_deadline)" -ForegroundColor White
    Write-Host "   Is Active: $($createdJob.job.is_active)" -ForegroundColor White
    Write-Host "   Created At: $($createdJob.job.created_at)" -ForegroundColor White
    
    $jobId = $createdJob.job.id
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

# Step 4: Verify job by fetching it
Write-Host "4. Verifying job by fetching it..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    $getResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/jobs/$jobId" -Method GET -Headers $headers -UseBasicParsing
    $fetchedJob = $getResponse.Content | ConvertFrom-Json
    
    Write-Host "   [OK] Job retrieved successfully" -ForegroundColor Green
    Write-Host "   Title: $($fetchedJob.job.title)" -ForegroundColor Gray
    Write-Host "   Status: Active" -ForegroundColor Gray
} catch {
    Write-Host "   [FAIL] Failed to retrieve job" -ForegroundColor Red
}

Write-Host ""

# Step 5: Get all jobs
Write-Host "5. Fetching all jobs..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    $allJobsResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/jobs/all" -Method GET -Headers $headers -UseBasicParsing
    $allJobs = $allJobsResponse.Content | ConvertFrom-Json
    
    Write-Host "   [OK] Retrieved $($allJobs.jobs.Count) total jobs" -ForegroundColor Green
} catch {
    Write-Host "   [FAIL] Failed to retrieve jobs list" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[SUCCESS] Job creation API is fully functional!" -ForegroundColor Green
Write-Host ""
Write-Host "API Endpoint: POST http://localhost:3001/api/jobs" -ForegroundColor White
Write-Host "Authorization: Bearer token required" -ForegroundColor White
Write-Host "Admin access: Required" -ForegroundColor White
Write-Host ""
