#!/bin/bash

# API Testing Script for Multi Language Bloc Backend
# Usage: ./test_api.sh

BASE_URL="http://localhost:8080"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  Multi Language Bloc API Test Suite"
echo "=========================================="
echo ""

# Test data
EMAIL="test-$(date +%s)@example.com"
PASSWORD="password123"
NAME="Test User"

# Function to print test results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
        exit 1
    fi
}

# Function to make API calls
api_call() {
    local method=$1
    local endpoint=$2
    local data=$3
    local token=$4
    
    if [ -n "$token" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" "${BASE_URL}${endpoint}" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -d "$data")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "${BASE_URL}${endpoint}" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    
    echo "$response"
}

echo "1. Testing Health Endpoints"
echo "----------------------------"

# Test Gateway Health
response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/health")
status_code=$(echo "$response" | tail -n1)
if [ "$status_code" -eq 200 ]; then
    print_result 0 "Gateway health check"
else
    print_result 1 "Gateway health check (Got: $status_code)"
fi

# Test Auth Service Health
response=$(curl -s -w "\n%{http_code}" "http://localhost:8081/health")
status_code=$(echo "$response" | tail -n1)
if [ "$status_code" -eq 200 ]; then
    print_result 0 "Auth service health check"
else
    print_result 1 "Auth service health check (Got: $status_code)"
fi

echo ""
echo "2. Testing User Registration"
echo "----------------------------"

register_data="{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\",\"name\":\"$NAME\"}"
response=$(api_call "POST" "/api/v1/auth/register" "$register_data")
status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$status_code" -eq 200 ] || [ "$status_code" -eq 201 ]; then
    print_result 0 "User registration"
    ACCESS_TOKEN=$(echo "$body" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
    REFRESH_TOKEN=$(echo "$body" | grep -o '"refresh_token":"[^"]*' | cut -d'"' -f4)
    echo -e "${YELLOW}   Access Token: ${ACCESS_TOKEN:0:20}...${NC}"
else
    print_result 1 "User registration (Status: $status_code)"
fi

echo ""
echo "3. Testing User Login"
echo "----------------------------"

login_data="{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}"
response=$(api_call "POST" "/api/v1/auth/login" "$login_data")
status_code=$(echo "$response" | tail -n1)

if [ "$status_code" -eq 200 ]; then
    print_result 0 "User login"
else
    print_result 1 "User login (Status: $status_code)"
fi

echo ""
echo "4. Testing Get Profile (Protected)"
echo "----------------------------"

response=$(api_call "GET" "/api/v1/user/profile" "" "$ACCESS_TOKEN")
status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$status_code" -eq 200 ]; then
    print_result 0 "Get user profile"
    echo -e "${YELLOW}   User: $(echo "$body" | grep -o '"name":"[^"]*' | cut -d'"' -f4)${NC}"
else
    print_result 1 "Get user profile (Status: $status_code)"
fi

echo ""
echo "5. Testing Update Profile (Protected)"
echo "----------------------------"

update_data="{\"name\":\"Updated Name\"}"
response=$(api_call "PUT" "/api/v1/user/profile" "$update_data" "$ACCESS_TOKEN")
status_code=$(echo "$response" | tail -n1)

if [ "$status_code" -eq 200 ]; then
    print_result 0 "Update user profile"
else
    print_result 1 "Update user profile (Status: $status_code)"
fi

echo ""
echo "6. Testing Get Usage Stats (Protected)"
echo "----------------------------"

response=$(api_call "GET" "/api/v1/user/usage" "" "$ACCESS_TOKEN")
status_code=$(echo "$response" | tail -n1)

if [ "$status_code" -eq 200 ]; then
    print_result 0 "Get usage statistics"
else
    print_result 1 "Get usage statistics (Status: $status_code)"
fi

echo ""
echo "7. Testing Token Refresh"
echo "----------------------------"

refresh_data="{\"refresh_token\":\"$REFRESH_TOKEN\"}"
response=$(api_call "POST" "/api/v1/auth/refresh" "$refresh_data")
status_code=$(echo "$response" | tail -n1)

if [ "$status_code" -eq 200 ]; then
    print_result 0 "Token refresh"
    NEW_ACCESS_TOKEN=$(echo "$response" | head -n-1 | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
    echo -e "${YELLOW}   New Access Token: ${NEW_ACCESS_TOKEN:0:20}...${NC}"
else
    print_result 1 "Token refresh (Status: $status_code)"
fi

echo ""
echo "8. Testing Unauthorized Access"
echo "----------------------------"

response=$(api_call "GET" "/api/v1/user/profile" "" "invalid-token")
status_code=$(echo "$response" | tail -n1)

if [ "$status_code" -eq 401 ]; then
    print_result 0 "Unauthorized access rejection"
else
    print_result 1 "Unauthorized access rejection (Expected 401, Got: $status_code)"
fi

echo ""
echo "9. Testing Delete Account (Protected)"
echo "----------------------------"

response=$(api_call "DELETE" "/api/v1/auth/account" "" "$ACCESS_TOKEN")
status_code=$(echo "$response" | tail -n1)

if [ "$status_code" -eq 200 ]; then
    print_result 0 "Delete user account"
else
    print_result 1 "Delete user account (Status: $status_code)"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}  All tests passed! ✓${NC}"
echo "=========================================="
