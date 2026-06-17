#!/bin/bash
# Payment Controller cURL Test Script
# Usage: bash PaymentController.curl.sh

BASE_URL="http://localhost:8080"
CONTENT_TYPE="application/json"

echo "=========================================="
echo "Payment Controller HTTP Test Suite"
echo "=========================================="
echo ""

# Test 1: Valid Payment Request - Basic
echo "Test 1: Valid Payment Request - Basic"
curl -X POST "${BASE_URL}/payments" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d '{
    "id": "PAY-001",
    "dateTime": "2024-01-15T10:30:00",
    "value": "100.50"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo "----------------------------------------"
echo ""

# Test 2: Valid Payment Request - Large Amount
echo "Test 2: Valid Payment Request - Large Amount"
curl -X POST "${BASE_URL}/payments" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d '{
    "id": "PAY-002",
    "dateTime": "2024-01-15T14:45:30",
    "value": "9999.99"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo "----------------------------------------"
echo ""

# Test 3: Valid Payment Request - Small Amount
echo "Test 3: Valid Payment Request - Small Amount"
curl -X POST "${BASE_URL}/payments" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d '{
    "id": "PAY-003",
    "dateTime": "2024-01-15T09:00:00",
    "value": "0.01"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo "----------------------------------------"
echo ""

# Test 4: Valid Payment Request - UUID as ID
echo "Test 4: Valid Payment Request - UUID as ID"
curl -X POST "${BASE_URL}/payments" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d '{
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "dateTime": "2024-01-15T12:00:00",
    "value": "250.75"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo "----------------------------------------"
echo ""

# Test 5: Edge Case - Empty String Values
echo "Test 5: Edge Case - Empty String Values"
curl -X POST "${BASE_URL}/payments" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d '{
    "id": "",
    "dateTime": "",
    "value": ""
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo "----------------------------------------"
echo ""

# Test 6: Edge Case - Missing Fields
echo "Test 6: Edge Case - Missing Fields"
curl -X POST "${BASE_URL}/payments" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d '{
    "id": "PAY-005"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo "----------------------------------------"
echo ""

# Test 7: Edge Case - Extra Fields
echo "Test 7: Edge Case - Extra Fields"
curl -X POST "${BASE_URL}/payments" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d '{
    "id": "PAY-006",
    "dateTime": "2024-01-15T10:30:00",
    "value": "100.50",
    "extraField": "should not be here"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo "----------------------------------------"
echo ""

# Test 8: Edge Case - Negative Value
echo "Test 8: Edge Case - Negative Value"
curl -X POST "${BASE_URL}/payments" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d '{
    "id": "PAY-007",
    "dateTime": "2024-01-15T10:30:00",
    "value": "-100.50"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo "----------------------------------------"
echo ""

# Test 9: Edge Case - Zero Value
echo "Test 9: Edge Case - Zero Value"
curl -X POST "${BASE_URL}/payments" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d '{
    "id": "PAY-008",
    "dateTime": "2024-01-15T10:30:00",
    "value": "0"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo "----------------------------------------"
echo ""

# Test 10: Edge Case - Invalid DateTime Format
echo "Test 10: Edge Case - Invalid DateTime Format"
curl -X POST "${BASE_URL}/payments" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  -d '{
    "id": "PAY-009",
    "dateTime": "invalid-date-format",
    "value": "100.50"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo "=========================================="
echo "Test Suite Completed"
echo "=========================================="


