#!/bin/bash
# Load project configuration

CONFIG_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/project.conf"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Error: Configuration file not found: $CONFIG_FILE" >&2
    exit 1
fi

# Validate required variables
validate_config() {
    local required_vars=("PACKAGE_NAME" "PACKAGE_VERSION" "PACKAGE_MAINTAINER")
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            echo "Error: Required configuration variable $var is not set" >&2
            exit 1
        fi
    done
}

validate_config
