#!/bin/bash
# Master test runner for all scripts
# This script will attempt to run all tests and report which ones succeed

echo "=========================================="
echo "Test Suite Runner"
echo "=========================================="
echo ""

# Get the directory where this script is located
TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$TEST_DIR"

PASSED=0
FAILED=0
SKIPPED=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Running tests..."
echo ""

# Test 1: rmseq_SSR_count.sh
echo "Test 1: rmseq_SSR_count.sh"
echo "----------------------------"
if bash test_rmseq_SSR_count.sh > /tmp/test1.log 2>&1; then
    echo -e "${GREEN}✓ PASSED${NC}"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗ FAILED${NC}"
    echo "See /tmp/test1.log for details"
    FAILED=$((FAILED+1))
fi
echo ""

# Test 2: get_gap_ambiguous_snp_score.sh
echo "Test 2: get_gap_ambiguous_snp_score.sh"
echo "---------------------------------------"
if command -v trimal &> /dev/null; then
    if bash test_get_gap_ambiguous_snp_score.sh > /tmp/test2.log 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        PASSED=$((PASSED+1))
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "See /tmp/test2.log for details"
        FAILED=$((FAILED+1))
    fi
else
    echo -e "${YELLOW}⊘ SKIPPED (trimal not installed)${NC}"
    SKIPPED=$((SKIPPED+1))
fi
echo ""

# Test 3: sample_run_gubbins.sh
echo "Test 3: sample_run_gubbins.sh"
echo "------------------------------"
if command -v run_gubbins.py &> /dev/null; then
    if bash test_sample_run_gubbins.sh > /tmp/test3.log 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        PASSED=$((PASSED+1))
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "See /tmp/test3.log for details"
        FAILED=$((FAILED+1))
    fi
else
    echo -e "${YELLOW}⊘ SKIPPED (Gubbins not installed)${NC}"
    SKIPPED=$((SKIPPED+1))
fi
echo ""

# Test 4: homoplastic_score.R
echo "Test 4: homoplastic_score.R"
echo "---------------------------"
if command -v Rscript &> /dev/null; then
    if bash test_homoplastic_score.sh > /tmp/test4.log 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        PASSED=$((PASSED+1))
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "See /tmp/test4.log for details"
        FAILED=$((FAILED+1))
    fi
else
    echo -e "${YELLOW}⊘ SKIPPED (R not installed)${NC}"
    SKIPPED=$((SKIPPED+1))
fi
echo ""

# Test 5: hetero_SSR_call.sh
echo "Test 5: hetero_SSR_call.sh"
echo "--------------------------"
MISSING=""
command -v bwa &> /dev/null || MISSING="bwa "
command -v samtools &> /dev/null || MISSING="${MISSING}samtools "
command -v lofreq &> /dev/null || MISSING="${MISSING}lofreq "
command -v vcfallelicprimitives &> /dev/null || MISSING="${MISSING}vcflib "

if [ -z "$MISSING" ]; then
    if bash test_hetero_SSR_call.sh > /tmp/test5.log 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        PASSED=$((PASSED+1))
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "See /tmp/test5.log for details"
        FAILED=$((FAILED+1))
    fi
else
    echo -e "${YELLOW}⊘ SKIPPED (missing: $MISSING)${NC}"
    SKIPPED=$((SKIPPED+1))
fi
echo ""

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "${GREEN}Passed:  $PASSED${NC}"
echo -e "${RED}Failed:  $FAILED${NC}"
echo -e "${YELLOW}Skipped: $SKIPPED${NC}"
echo "Total:   $((PASSED+FAILED+SKIPPED))"
echo ""

if [ $FAILED -gt 0 ]; then
    exit 1
else
    exit 0
fi
