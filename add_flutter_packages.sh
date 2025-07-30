#!/bin/bash

# Flutter Packages Installation Script - File-based Version

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[HEADER]${NC} $1"
}

# Show usage information
show_usage() {
    echo "Usage: $0 [package_file]"
    echo ""
    echo "Supported file formats:"
    echo "  • JSON: {\"packages\": [\"package1\", \"package2\"]}"
    echo "  • Text: One package per line"
    echo "  • Space-separated: \"package1 package2 package3\""
    echo ""
    echo "Examples:"
    echo "  $0 packages.json"
    echo "  $0 core_packages.txt"
    echo "  $0 ui_packages.list"
    echo ""
    echo "If no file is provided, will use default packages list"
}

# Check if we're in a Flutter project
check_flutter_project() {
    if [ ! -f "pubspec.yaml" ]; then
        print_error "pubspec.yaml not found. Are you in a Flutter project directory?"
        exit 1
    fi
    
    if ! grep -q "flutter:" pubspec.yaml; then
        print_error "This doesn't appear to be a Flutter project (no flutter: section in pubspec.yaml)"
        exit 1
    fi
    
    print_status "Flutter project detected"
}

# Check if Flutter is installed
check_flutter_installed() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        print_status "Please install Flutter: https://docs.flutter.dev/get-started/install"
        exit 1
    fi
    
    print_status "Flutter is installed: $(flutter --version | head -1)"
}

# Parse JSON file to extract packages
parse_json_file() {
    local file=$1
    
    # Check if jq is available
    if command -v jq &> /dev/null; then
        jq -r '.packages[]' "$file" 2>/dev/null
    else
        # Fallback: basic JSON parsing without jq (improved for macOS)
        print_warning "jq not found, using basic JSON parsing"
        # Extract content between [ and ]
        sed -n '/\[/,/\]/p' "$file" | \
        grep -o '"[^"]*"' | \
        tr -d '"' | \
        grep -v "packages"
    fi
}

# Parse text file (one package per line)
parse_text_file() {
    local file=$1
    # Remove empty lines and comments (lines starting with #)
    grep -v '^#' "$file" | grep -v '^$' | tr -d '\r'
}

# Parse space-separated file
parse_space_separated() {
    local file=$1
    tr ' \n\t' '\n' < "$file" | grep -v '^$'
}

# Read packages from file
read_packages_from_file() {
    local file=$1
    
    if [ ! -f "$file" ]; then
        print_error "Package file '$file' not found!"
        return 1
    fi
    
    print_status "Reading packages from: $file"
    
    # Clear packages array
    PACKAGES=()
    
    # Detect file format and parse accordingly
    if [[ "$file" == *.json ]]; then
        print_status "Detected JSON format"
        # Read packages using while loop (macOS compatible)
        while IFS= read -r package; do
            if [[ -n "$package" && "$package" != "packages" ]]; then
                PACKAGES+=("$package")
            fi
        done < <(parse_json_file "$file")
    elif [[ "$file" == *.txt ]] || [[ "$file" == *.list ]]; then
        print_status "Detected text format (one package per line)"
        while IFS= read -r package; do
            if [[ -n "$package" && "$package" != "packages" ]]; then
                PACKAGES+=("$package")
            fi
        done < <(parse_text_file "$file")
    else
        # Try to auto-detect format
        if grep -q '{.*"packages".*\[' "$file" 2>/dev/null; then
            print_status "Auto-detected JSON format"
            while IFS= read -r package; do
                if [[ -n "$package" && "$package" != "packages" ]]; then
                    PACKAGES+=("$package")
                fi
            done < <(parse_json_file "$file")
        else
            print_status "Treating as space-separated or line-separated format"
            while IFS= read -r package; do
                if [[ -n "$package" && "$package" != "packages" ]]; then
                    PACKAGES+=("$package")
                fi
            done < <(parse_space_separated "$file")
        fi
    fi
    
    if [ ${#PACKAGES[@]} -eq 0 ]; then
        print_error "No packages found in file '$file'"
        print_status "File contents:"
        cat "$file"
        return 1
    fi
    
    print_status "Found ${#PACKAGES[@]} packages:"
    for pkg in "${PACKAGES[@]}"; do
        echo "   • $pkg"
    done
    echo ""
    
    return 0
}

# Get default packages if no file provided
get_default_packages() {
    print_status "Using default packages list"
    PACKAGES=(
        "flutter_secure_storage"
        "equatable"
        "flutter_login"
        "go_router"
        "flutter_bloc"
        "nakama"
    )
}

# Function to add a package
add_package() {
    local package_name=$1
    print_status "Adding package: $package_name"
    
    if flutter pub add "$package_name"; then
        print_status "✅ Successfully added $package_name"
    else
        print_error "❌ Failed to add $package_name"
        return 1
    fi
}

# Create example files
create_example_files() {
    print_status "Creating example package files..."
    
    # Create JSON example
    cat > "example_packages.json" << 'EOF'
{
  "packages": [
    "flutter_secure_storage",
    "equatable",
    "flutter_login",
    "go_router",
    "flutter_bloc",
    "nakama"
  ]
}
EOF
    
    # Create text example
    cat > "example_packages.txt" << 'EOF'
# Core packages for authentication and storage
flutter_secure_storage
equatable

# UI packages
flutter_login

# Navigation
go_router

# State management
flutter_bloc

# Backend
nakama
EOF
    
    # Create space-separated example
    echo "http dio shared_preferences provider" > "example_http_packages.txt"
    
    print_status "Created example files:"
    echo "   • example_packages.json"
    echo "   • example_packages.txt" 
    echo "   • example_http_packages.txt"
}

# Main script
print_header "🚀 Flutter Packages Installation Script (File-based)"
print_header "=================================================="

# Handle help flag
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_usage
    exit 0
fi

# Handle create examples flag
if [ "$1" == "--create-examples" ]; then
    create_example_files
    exit 0
fi

# Pre-flight checks
print_status "Running pre-flight checks..."
check_flutter_project
check_flutter_installed

# Get packages list
declare -a PACKAGES
if [ -n "$1" ]; then
    if ! read_packages_from_file "$1"; then
        exit 1
    fi
else
    get_default_packages
fi

print_header "📦 Installing ${#PACKAGES[@]} Flutter packages..."
echo ""

# Track installation results
failed_packages=()
successful_packages=()

# Install each package
for package in "${PACKAGES[@]}"; do
    if add_package "$package"; then
        successful_packages+=("$package")
    else
        failed_packages+=("$package")
    fi
    echo ""  # Add spacing between packages
done

# Summary
print_header "📋 Installation Summary"
print_header "======================="

if [ ${#successful_packages[@]} -gt 0 ]; then
    print_status "✅ Successfully installed packages (${#successful_packages[@]}):"
    for package in "${successful_packages[@]}"; do
        echo "   • $package"
    done
    echo ""
fi

if [ ${#failed_packages[@]} -gt 0 ]; then
    print_error "❌ Failed to install packages (${#failed_packages[@]}):"
    for package in "${failed_packages[@]}"; do
        echo "   • $package"
    done
    echo ""
    print_warning "You may need to install these manually:"
    for package in "${failed_packages[@]}"; do
        echo "   flutter pub add $package"
    done
    echo ""
fi

# Run flutter pub get to ensure everything is properly resolved
print_status "Running flutter pub get to resolve dependencies..."
if flutter pub get; then
    print_status "✅ Dependencies resolved successfully"
else
    print_error "❌ Failed to resolve dependencies"
fi

echo ""
print_header "🎉 Package installation complete!"

# Show next steps
print_header "📚 Next Steps:"
echo "1. Import packages in your Dart files as needed"
echo "2. Check pubspec.yaml to verify all packages were added"
echo "3. Run 'flutter doctor' if you encounter any issues"
echo ""
echo "💡 Tip: Create more package files for different project types!"
echo "   Run: $0 --create-examples"
echo ""

# Optional: Show current pubspec.yaml dependencies
if [ "$2" == "--show-deps" ] || [ "$1" == "--show-deps" ]; then
    print_header "📄 Current dependencies in pubspec.yaml:"
    echo ""
    grep -A 30 "dependencies:" pubspec.yaml | head -40
fi