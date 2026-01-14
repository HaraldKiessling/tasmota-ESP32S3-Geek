#!/bin/bash
# Upload files to Tasmota via Berry scripting
# This works when normal HTTP upload fails

set +e

TASMOTA_URL="${TASMOTA_URL:-}"
if [ -z "$TASMOTA_URL" ]; then
    echo "ERROR: TASMOTA_URL not set"
    echo "Usage: TASMOTA_URL=http://192.168.0.77 ./upload-via-berry.sh <file>"
    exit 1
fi

TASMOTA_URL="${TASMOTA_URL%/}"
FILE="$1"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
    echo "ERROR: File not found: $FILE"
    exit 1
fi

FILENAME=$(basename "$FILE")
echo "Uploading $FILENAME to $TASMOTA_URL via Berry..."

# Create/truncate file
echo -n "  Creating file... "
RESULT=$(curl -s --max-time 10 --get --data-urlencode "cmnd=br f=open('$FILENAME','w') f.close()" "$TASMOTA_URL/cm")
if echo "$RESULT" | grep -q "Br"; then
    echo "OK"
else
    echo "FAILED: $RESULT"
    exit 1
fi

# Read file and upload line by line
LINENUM=0
while IFS= read -r line || [ -n "$line" ]; do
    LINENUM=$((LINENUM + 1))
    
    # Escape special characters for URL and Berry string
    # Replace \ with \\, ' with \', " with \"
    ESCAPED=$(echo "$line" | sed "s/\\\\/\\\\\\\\/g; s/'/\\\\'/g; s/\"/\\\\\"/g")
    
    # Write line via Berry
    CMD="br f=open('$FILENAME','a') f.write('$ESCAPED\\n') f.close()"
    RESULT=$(curl -s --max-time 10 --get --data-urlencode "cmnd=$CMD" "$TASMOTA_URL/cm" 2>/dev/null)
    
    if ! echo "$RESULT" | grep -q "Br"; then
        echo ""
        echo "ERROR at line $LINENUM: $RESULT"
        echo "Line content: $line"
        exit 1
    fi
    
    # Progress indicator
    if [ $((LINENUM % 10)) -eq 0 ]; then
        echo -n "."
    fi
done < "$FILE"

echo ""
echo "  Uploaded $LINENUM lines"

# Verify
echo -n "  Verifying... "
RESULT=$(curl -s --max-time 10 --get --data-urlencode "cmnd=br import path print(path.exists('$FILENAME'))" "$TASMOTA_URL/cm")
if echo "$RESULT" | grep -q "true"; then
    echo "OK"
else
    echo "File may not exist: $RESULT"
fi

echo "Done!"
