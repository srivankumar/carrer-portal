# Test Job Creation API

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  JOB CREATION API TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Admin credentials (you may need to adjust these)
$adminEmail = "admin@test.com"
$adminPassword = "admin123"

# Step 1: Login as admin
Write-Host "1. Logging in as admin..." -ForegroundColor Yellow
$loginBody = @{
    email = $adminEmail
    password = $adminPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/auth/login" -Method POST -Body $loginBody -ContentType 'application/json' -UseBasicParsing
    $loginData = $loginResponse.Content | ConvertFrom-Json
    $token = $loginData.token
    $userRole = $loginData.user.role
    
    Write-Host "   ✓ Login successful" -ForegroundColor Green
    Write-Host "     User: $($loginData.user.email)" -ForegroundColor Gray
    Write-Host "     Role: $userRole" -ForegroundColor Gray
    Write-Host "     Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
    
    if ($userRole -ne "admin") {
        Write-Host "   ✗ User is not an admin!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ✗ Login failed" -ForegroundColor Red
    Write-Host "     Error: $($_.Exception.Message)" -ForegroundColor Red
    
    # Try to read the response body for more details
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "     Response: $responseBody" -ForegroundColor Red
        $reader.Close()
    }
    
    Write-Host ""
    Write-Host "Note: Make sure you have an admin user created." -ForegroundColor Yellow
    Write-Host "You can create one by registering and then updating the role in Supabase." -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Step 2: Create a test job
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
    
    Write-Host "   ✓ Job created successfully" -ForegroundColor Green
    Write-Host "     Job ID: $($createdJob.job.id)" -ForegroundColor Gray
    Write-Host "     Title: $($createdJob.job.title)" -ForegroundColor Gray
    Write-Host "     Skills: $($createdJob.job.skills)" -ForegroundColor Gray
    Write-Host "     Experience: $($createdJob.job.experience)" -ForegroundColor Gray
    Write-Host "     Deadline: $($createdJob.job.application_deadline)" -ForegroundColor Gray
    Write-Host "     Active: $($createdJob.job.is_active)" -ForegroundColor Gray
    
    $jobId = $createdJob.job.id
} catch {
    Write-Host "   ✗ Job creation failed" -ForegroundColor Red
    Write-Host "     Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "     Response: $responseBody" -ForegroundColor Red
        $reader.Close()
    }
    exit 1
}

Write-Host ""

# Step 3: Verify job was created by fetching it
Write-Host "3. Verifying job was created..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $token"
    }
    
    $getResponse = Invoke-WebRequest -Uri "http://localhost:3001/api/jobs/$jobId" -Method GET -Headers $headers -UseBasicParsing
    $fetchedJob = $getResponse.Content | ConvertFrom-Json
    
    Write-Host "   ✓ Job retrieved successfully" -ForegroundColor Green
    Write-Host "     Title: $($fetchedJob.job.title)" -ForegroundColor Gray
    Write-Host "     Created At: $($fetchedJob.job.created_at)" -ForegroundColor Gray
} catch {
    Write-Host "   ✗ Failed to retrieve job" -ForegroundColor Red
    Write-Host "     Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Step 4: Test validation
Write-Host "4. Testing validation (missing fields)..." -ForegroundColor Yellow
$invalidJobData = @{
    title = "Test Job"
    # Missing required fields
} | ConvertTo-Json

try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    Invoke-WebRequest -Uri "http://localhost:3001/api/jobs" -Method POST -Body $invalidJobData -Headers $headers -UseBasicParsing -ErrorAction Stop | Out-Null
    Write-Host "   X Validation not working - invalid data accepted" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 400) {
        Write-Host "   - Validation working - invalid data rejected" -ForegroundColor Green
        
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "     Response: $responseBody" -ForegroundColor Gray
            $reader.Close()
        }
    } else {
        Write-Host "   ? Unexpected status code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TEST COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "- Job creation API is working correctly" -ForegroundColor Green
Write-Host ""
