#!/bin/bash

# Script to update coverage badge and generate HTML reports
# Usage: ./scripts/update_coverage.sh

set -e

echo "🧪 Running tests with coverage..."
# Check if test directory exists
if [ ! -d "test" ]; then
    echo "⚠️  No test directory found. Creating minimal coverage report..."
    
    # Create empty coverage directory and files
    mkdir -p coverage
    echo "TN:" > coverage/lcov.info
    echo "end_of_record" >> coverage/lcov.info
    
    # Set coverage to 0%
    COVERAGE="0.0%"
    echo "Coverage: $COVERAGE (no tests found)"
    
    # Skip HTML report generation since there's no coverage data
    echo "📊 Skipping HTML report generation (no tests)"
else
    flutter test --coverage
    
    
    echo "📊 Generating HTML coverage report..."
    # Check if genhtml is installed
    if ! command -v genhtml &> /dev/null; then
        echo "⚠️  genhtml not found. Installing lcov..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if command -v brew &> /dev/null; then
                brew install lcov
            else
                echo "❌ Homebrew not found. Please install Homebrew first or install lcov manually."
                echo "   Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                echo "   Then run: brew install lcov"
                exit 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y lcov
            elif command -v yum &> /dev/null; then
                sudo yum install -y lcov
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y lcov
            else
                echo "❌ Package manager not found. Please install lcov manually."
                exit 1
            fi
        elif [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]] || [[ "$OSTYPE" == "win32"* ]]; then
            # Windows
            if command -v choco &> /dev/null; then
                echo "📦 Installing lcov via Chocolatey..."
                choco install lcov -y
            elif command -v scoop &> /dev/null; then
                echo "📦 Installing lcov via Scoop..."
                scoop install lcov
            elif command -v winget &> /dev/null; then
                echo "📦 Installing lcov via winget..."
                winget install lcov
            else
                echo "❌ No package manager found on Windows."
                echo "   Please install one of the following:"
                echo "   • Chocolatey: https://chocolatey.org/install"
                echo "   • Scoop: https://scoop.sh/"
                echo "   • Or install lcov manually from: https://github.com/linux-test-project/lcov"
                echo "   • Alternative: Use WSL (Windows Subsystem for Linux)"
                exit 1
            fi
        else
            echo "❌ Unsupported OS: $OSTYPE"
            echo "   Please install lcov manually or use one of the supported systems:"
            echo "   • macOS (with Homebrew)"
            echo "   • Linux (with apt-get, yum, or dnf)"
            echo "   • Windows (with Chocolatey, Scoop, or winget)"
            exit 1
        fi
        echo "✅ lcov installed successfully!"
    fi

    genhtml coverage/lcov.info -o coverage/html
    

    echo "📈 Extracting coverage percentage..."
    COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | grep -o '[0-9]\+\.[0-9]\+%' | head -1)
    echo "Coverage: $COVERAGE"
fi

echo "🏷️ Creating/updating coverage badge..."
# Color based on coverage percentage
COVERAGE_NUM=$(echo $COVERAGE | sed 's/%//')
if (( $(echo "$COVERAGE_NUM >= 90" | bc -l) )); then
    COLOR="#44cc11"  # Green
elif (( $(echo "$COVERAGE_NUM >= 80" | bc -l) )); then
    COLOR="#dfb317"  # Yellow
elif (( $(echo "$COVERAGE_NUM >= 70" | bc -l) )); then
    COLOR="#fe7d37"  # Orange
else
    COLOR="#e05d44"  # Red
fi

# Create or update the SVG badge
if [ ! -f "coverage_badge.svg" ]; then
    echo "📋 Creating new coverage badge..."
    cat > coverage_badge.svg << EOF
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="102" height="20" role="img" aria-label="coverage: $COVERAGE">
    <title>coverage: $COVERAGE</title>
    <linearGradient id="s" x2="0" y2="100%">
        <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
        <stop offset="1" stop-opacity=".1"/>
    </linearGradient>
    <clipPath id="r">
        <rect width="102" height="20" rx="3" fill="#fff"/>
    </clipPath>
    <g clip-path="url(#r)">
        <rect width="59" height="20" fill="#555"/>
        <rect x="59" width="43" height="20" fill="$COLOR"/>
        <rect width="102" height="20" fill="url(#s)"/>
    </g>
    <g fill="#fff" text-anchor="middle" font-family="Verdana,Geneva,DejaVu Sans,sans-serif" text-rendering="geometricPrecision" font-size="110">
        <text aria-hidden="true" x="305" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)" textLength="490">coverage</text>
        <text x="305" y="140" transform="scale(.1)" fill="#fff" textLength="490">coverage</text>
        <text aria-hidden="true" x="795" y="150" fill="#010101" fill-opacity=".3" transform="scale(.1)" textLength="330">$COVERAGE</text>
        <text x="795" y="140" transform="scale(.1)" fill="#fff" textLength="330">$COVERAGE</text>
    </g>
</svg>
EOF
else
    echo "📋 Updating existing coverage badge..."
    # Update the SVG badge
    sed -i.bak "s/fill=\"#[^\"]*\" d=\"M59 0h43v20H59z\"/fill=\"$COLOR\" d=\"M59 0h43v20H59z\"/g" coverage_badge.svg
    sed -i.bak "s/textLength=\"330\">[^<]*%<\/text>/textLength=\"330\">$COVERAGE<\/text>/g" coverage_badge.svg
    sed -i.bak "s/aria-label=\"coverage: [^\"]*\"/aria-label=\"coverage: $COVERAGE\"/g" coverage_badge.svg
    sed -i.bak "s/<title>coverage: [^<]*<\/title>/<title>coverage: $COVERAGE<\/title>/g" coverage_badge.svg
    sed -i.bak "s/x=\"59\" width=\"43\" height=\"20\" fill=\"#[^\"]*\"/x=\"59\" width=\"43\" height=\"20\" fill=\"$COLOR\"/g" coverage_badge.svg
    rm coverage_badge.svg.bak
fi

echo "✅ Coverage report generated successfully!"

if [ -d "coverage/html" ]; then
    echo "📂 HTML report: coverage/html/index.html"
else
    echo "📂 HTML report: skipped (no tests found)"
fi


echo "🏷️ Badge created/updated: coverage_badge.svg"
echo "📊 Overall coverage: $COVERAGE"
