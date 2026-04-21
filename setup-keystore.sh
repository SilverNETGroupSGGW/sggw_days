#!/bin/bash

# SGGW Days - Keystore Setup Helper Script
# This script helps generate and prepare the keystore for GitHub Actions deployment

set -e

echo "🔐 SGGW Days - Keystore Setup Helper"
echo "===================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo -e "${RED}❌ keytool not found. Please install Java Development Kit (JDK)${NC}"
    echo "   MacOS: brew install openjdk"
    echo "   Ubuntu: sudo apt-get install default-jdk"
    echo "   Windows: Download from https://www.oracle.com/java/technologies/downloads/"
    exit 1
fi

echo -e "${YELLOW}Step 1: Generate Release Keystore${NC}"
echo "This will create a new keystore for signing Android releases."
echo ""

KEYSTORE_FILE="upload-keystore.jks"
KEYSTORE_ALIAS="upload"
KEYSTORE_VALIDITY=10950  # 30 years

if [ -f "$KEYSTORE_FILE" ]; then
    echo -e "${YELLOW}⚠️  $KEYSTORE_FILE already exists!${NC}"
    read -p "Do you want to overwrite it? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing $KEYSTORE_FILE"
    else
        rm "$KEYSTORE_FILE"
    fi
fi

if [ ! -f "$KEYSTORE_FILE" ]; then
    echo "Run the following command to generate your keystore:"
    echo ""
    echo -e "${GREEN}keytool -genkey -v \\"
    echo "  -keystore $KEYSTORE_FILE \\"
    echo "  -keyalg RSA \\"
    echo "  -keysize 2048 \\"
    echo "  -validity $KEYSTORE_VALIDITY \\"
    echo "  -alias $KEYSTORE_ALIAS \\"
    echo "  -storetype JKS${NC}"
    echo ""
    echo "When prompted, enter:"
    echo "  - First/Last name: Your name or 'SGGW Days'"
    echo "  - Organization: SilverNET Group SGGW"
    echo "  - City: Your city"
    echo "  - State: Your state"
    echo "  - Country: PL (or your country code)"
    echo "  - Keystore password: Create a strong password"
    echo "  - Key password: Same as keystore password"
    echo ""
    read -p "Press Enter when ready to generate keystore..."
    
    keytool -genkey -v \
        -keystore "$KEYSTORE_FILE" \
        -keyalg RSA \
        -keysize 2048 \
        -validity $KEYSTORE_VALIDITY \
        -alias "$KEYSTORE_ALIAS" \
        -storetype JKS
    
    echo -e "${GREEN}✓ Keystore generated: $KEYSTORE_FILE${NC}"
fi

echo ""
echo -e "${YELLOW}Step 2: Encode Keystore as Base64${NC}"
echo "This creates a base64-encoded version for GitHub secrets."
echo ""

BASE64_FILE="keystore-base64.txt"

if [ -f "$BASE64_FILE" ]; then
    echo -e "${YELLOW}⚠️  $BASE64_FILE already exists. Regenerating...${NC}"
fi

cat "$KEYSTORE_FILE" | base64 | tr -d '\n' > "$BASE64_FILE"
echo -e "${GREEN}✓ Base64 encoded: $BASE64_FILE${NC}"

echo ""
echo "📋 GitHub Secrets to Create:"
echo "============================"
echo ""
echo "Go to your GitHub repository:"
echo "  Settings → Secrets and variables → Actions → New repository secret"
echo ""
echo "Create these secrets:"
echo ""
echo "1. Secret: KEYSTORE_BASE64"
echo "   Value: (copy from $BASE64_FILE)"
echo "   "

KEYSTORE_SIZE=$(wc -c < "$BASE64_FILE")
echo -e "${YELLOW}   File size: $KEYSTORE_SIZE bytes (this is normal)${NC}"
echo ""
echo "   To copy: cat $BASE64_FILE | xclip -selection clipboard"
echo "   Or on Mac: cat $BASE64_FILE | pbcopy"
echo ""
echo "2. Secret: KEYSTORE_ALIAS"
echo -e "   Value: ${GREEN}$KEYSTORE_ALIAS${NC}"
echo ""
echo "3. Secret: KEYSTORE_PASSWORD"
echo "   Value: (password you entered during generation)"
echo ""
echo "4. Secret: KEYSTORE_ALIAS_PASSWORD"
echo "   Value: (same as KEYSTORE_PASSWORD)"
echo ""
echo "5. Secret: FIREBASE_SERVICE_ACCOUNT_SGGW_DAYS"
echo "   Value: (shared JSON from Google Cloud service account with both Firebase Hosting and Google Play access)"
echo ""

echo -e "${YELLOW}Step 3: Display Base64 Content${NC}"
echo "Here's the content to paste into GitHub (KEYSTORE_BASE64 secret):"
echo "=================================================================="
echo ""

head -c 100 "$BASE64_FILE"
echo "...(truncated for display)"
echo ""
echo "Full content saved to: $BASE64_FILE"
echo ""

echo -e "${YELLOW}Step 4: Keystore Information${NC}"
echo "To verify your keystore:"
echo ""
echo "  keytool -list -v -keystore $KEYSTORE_FILE"
echo ""

echo -e "${GREEN}✅ Setup Complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Add the 5 secrets to GitHub (see details above)"
echo "2. Push your code: git push origin main"
echo "3. Watch the deployment in GitHub Actions"
echo ""
echo "For detailed instructions, see: DEPLOYMENT_GUIDE.md"
