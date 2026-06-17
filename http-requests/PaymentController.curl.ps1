# Payment Controller PowerShell cURL Test Script
# Usage: .\PaymentController.curl.ps1

$BaseUrl = "http://localhost:8080"
$ContentType = "application/json"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Payment Controller HTTP Test Suite" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Valid Payment Request - Basic
Write-Host "Test 1: Valid Payment Request - Basic" -ForegroundColor Yellow
$body1 = @{
    id = "PAY-001"
    dateTime = "2024-01-15T10:30:00"
    value = "100.50"
} | ConvertTo-Json

try {
    $response1 = Invoke-RestMethod -Uri "$BaseUrl/payments" -Method Post -Body $body1 -ContentType $ContentType
    Write-Host "Success: Request completed" -ForegroundColor Green
    $response1 | ConvertTo-Json
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}
Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""

# Test 2: Valid Payment Request - Large Amount
Write-Host "Test 2: Valid Payment Request - Large Amount" -ForegroundColor Yellow
$body2 = @{
    id = "PAY-002"
    dateTime = "2024-01-15T14:45:30"
    value = "9999.99"
} | ConvertTo-Json

try {
    $response2 = Invoke-RestMethod -Uri "$BaseUrl/payments" -Method Post -Body $body2 -ContentType $ContentType
    Write-Host "Success: Request completed" -ForegroundColor Green
    $response2 | ConvertTo-Json
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}
Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""

# Test 3: Valid Payment Request - Small Amount
Write-Host "Test 3: Valid Payment Request - Small Amount" -ForegroundColor Yellow
$body3 = @{
    id = "PAY-003"
    dateTime = "2024-01-15T09:00:00"
    value = "0.01"
} | ConvertTo-Json

try {
    $response3 = Invoke-RestMethod -Uri "$BaseUrl/payments" -Method Post -Body $body3 -ContentType $ContentType
    Write-Host "Success: Request completed" -ForegroundColor Green
    $response3 | ConvertTo-Json
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}
Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""

# Test 4: Valid Payment Request - UUID as ID
Write-Host "Test 4: Valid Payment Request - UUID as ID" -ForegroundColor Yellow
$body4 = @{
    id = "550e8400-e29b-41d4-a716-446655440000"
    dateTime = "2024-01-15T12:00:00"
    value = "250.75"
} | ConvertTo-Json

try {
    $response4 = Invoke-RestMethod -Uri "$BaseUrl/payments" -Method Post -Body $body4 -ContentType $ContentType
    Write-Host "Success: Request completed" -ForegroundColor Green
    $response4 | ConvertTo-Json
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}
Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""

# Test 5: Edge Case - Empty String Values
Write-Host "Test 5: Edge Case - Empty String Values" -ForegroundColor Yellow
$body5 = @{
    id = ""
    dateTime = ""
    value = ""
} | ConvertTo-Json

try {
    $response5 = Invoke-RestMethod -Uri "$BaseUrl/payments" -Method Post -Body $body5 -ContentType $ContentType
    Write-Host "Success: Request completed" -ForegroundColor Green
    $response5 | ConvertTo-Json
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}
Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""

# Test 6: Edge Case - Missing Fields
Write-Host "Test 6: Edge Case - Missing Fields" -ForegroundColor Yellow
$body6 = @{
    id = "PAY-005"
} | ConvertTo-Json

try {
    $response6 = Invoke-RestMethod -Uri "$BaseUrl/payments" -Method Post -Body $body6 -ContentType $ContentType
    Write-Host "Success: Request completed" -ForegroundColor Green
    $response6 | ConvertTo-Json
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}
Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""

# Test 7: Edge Case - Extra Fields
Write-Host "Test 7: Edge Case - Extra Fields" -ForegroundColor Yellow
$body7 = @{
    id = "PAY-006"
    dateTime = "2024-01-15T10:30:00"
    value = "100.50"
    extraField = "should not be here"
} | ConvertTo-Json

try {
    $response7 = Invoke-RestMethod -Uri "$BaseUrl/payments" -Method Post -Body $body7 -ContentType $ContentType
    Write-Host "Success: Request completed" -ForegroundColor Green
    $response7 | ConvertTo-Json
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}
Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""

# Test 8: Edge Case - Negative Value
Write-Host "Test 8: Edge Case - Negative Value" -ForegroundColor Yellow
$body8 = @{
    id = "PAY-007"
    dateTime = "2024-01-15T10:30:00"
    value = "-100.50"
} | ConvertTo-Json

try {
    $response8 = Invoke-RestMethod -Uri "$BaseUrl/payments" -Method Post -Body $body8 -ContentType $ContentType
    Write-Host "Success: Request completed" -ForegroundColor Green
    $response8 | ConvertTo-Json
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}
Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host ""

# Test 9: Edge Case - Zero Value
Write-Host "Test 9: Edge Case - Zero Value" -ForegroundColor Yellow
$body9 = @{
    id = "PAY-008"
    dateTime = "2024-01-15T10:30:00"
    value = "0"
} | ConvertTo-Json

try {
    $response9 = Invoke-RestMethod -Uri "$BaseUrl/payments" -Method Post -Body $body9 -ContentType $ContentType
    Write-Host "Success: Request completed" -ForegroundColor Green
    $response9 | ConvertTo-Json
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Test Suite Completed" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan


