#!/bin/zsh

# Initialize variables
local _push=false
local _dir_name=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --push)
            _push=true
            shift
            ;;
        -*)
            echo "Error: Unknown option $1"
            echo "Usage: $0 [--push] <directory_name>"
            echo "Example: $0 devmate"
            echo "Example: $0 --push devmate"
            exit 1
            ;;
        *)
            if [ -z "$_dir_name" ]; then
                _dir_name=$1
            else
                echo "Error: Multiple directory names provided"
                echo "Usage: $0 [--push] <directory_name>"
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if directory argument is provided
if [ -z "$_dir_name" ]; then
    echo "Usage: $0 [--push] <directory_name>"
    echo "Example: $0 devmate"
    echo "Example: $0 --push devmate"
    exit 1
fi

local _base_dir=$(dirname $0)
local _target_dir="$_base_dir/$_dir_name"

# Check if directory exists
if [ ! -d "$_target_dir" ]; then
    echo "Error: Directory '$_dir_name' does not exist in $_base_dir"
    exit 1
fi

# Check if Dockerfile exists in the directory
if [ ! -f "$_target_dir/Dockerfile" ]; then
    echo "Error: Dockerfile not found in $_target_dir"
    exit 1
fi

# Check if VERSION file exists in the directory
if [ ! -f "$_target_dir/VERSION" ]; then
    echo "Error: VERSION file not found in $_target_dir"
    exit 1
fi

# Read version from VERSION file
local _version=$(cat "$_target_dir/VERSION" | tr -d '\n\r')

# Build Docker image with both tags
echo "Building Docker image for $_dir_name..."
echo "Version: $_version"
echo "Building with tags: qubixds/${_dir_name}:latest and qubixds/${_dir_name}:$_version"

docker build -t "qubixds/${_dir_name}:latest" -t "qubixds/${_dir_name}:$_version" "$_target_dir"

if [ $? -eq 0 ]; then
    echo "Successfully built Docker image:"
    echo "  - qubixds/${_dir_name}:latest"
    echo "  - qubixds/${_dir_name}:$_version"
else
    echo "Error: Docker build failed"
    exit 1
fi

# Push images if --push flag is provided
if [ "$_push" = true ]; then
    echo "Pushing images to registry..."
    
    echo "Pushing qubixds/${_dir_name}:latest..."
    docker push "qubixds/${_dir_name}:latest"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to push qubixds/${_dir_name}:latest"
        exit 1
    fi
    
    echo "Pushing qubixds/${_dir_name}:$_version..."
    docker push "qubixds/${_dir_name}:$_version"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to push qubixds/${_dir_name}:$_version"
        exit 1
    fi
    
    echo "Successfully pushed both images to registry"
fi
