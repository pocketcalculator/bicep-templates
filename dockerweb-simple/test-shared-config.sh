#!/bin/bash

# test-shared-config.sh - Test the shared configuration system
echo "Testing shared configuration system..."
echo ""

# Clean up any existing config
rm -f deployment-config.txt

echo "=== First run (should create new config) ==="
source ./shared-config.sh
echo ""

echo "=== Second run (should reuse existing config) ==="
source ./shared-config.sh
echo ""

echo "=== Configuration file contents ==="
cat deployment-config.txt
echo ""

echo "Test completed. The same suffix should be used in both runs."
