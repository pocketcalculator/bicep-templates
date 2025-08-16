#!/bin/bash

# =============================================================================
# General Purpose Key Vault Bicep Template Deployment Script
# =============================================================================
# This script deploys a general-purpose Key Vault Bicep template with 
# comprehensive error handling, parameter validation, and deployment options.
#
# Usage: ./deploy-keyvault.sh [OPTIONS]
# =============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BICEP_FILE="$SCRIPT_DIR/keyvault.bicep"
DEPLOYMENT_NAME="keyvault-deployment-$(date +%Y%m%d-%H%M%S)"

# Default values
RESOURCE_GROUP=""
LOCATION="eastus"
SUBSCRIPTION_ID=""
ENVIRONMENT="dev"
DRY_RUN=false
VERBOSE=false
PARAMETER_FILE=""
SECRET_FILE=""
CREATE_RESOURCE_GROUP=false
SKIP_WHAT_IF=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# Helper Functions
# =============================================================================

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy Azure Key Vault using Bicep template for general subscription use

OPTIONS:
    -g, --resource-group RESOURCE_GROUP    Resource group name (required)
    -l, --location LOCATION               Azure location (default: eastus)
    -s, --subscription SUBSCRIPTION_ID    Azure subscription ID
    -e, --environment ENVIRONMENT         Environment tag (default: dev)
    -p, --parameters PARAMETER_FILE       Path to parameters file
    -f, --secret-file SECRET_FILE         Path to secret file to store in vault
    -n, --deployment-name NAME            Custom deployment name
    -c, --create-resource-group          Create resource group if it doesn't exist
    -d, --dry-run                        Perform validation only (what-if)
    -w, --skip-what-if                   Skip what-if analysis
    -v, --verbose                        Enable verbose output
    -h, --help                           Show this help message

EXAMPLES:
    # Basic deployment
    $0 -g my-rg -l westus2

    # Deploy with secret file
    $0 -g my-rg -l westus2 -f /path/to/secret.txt

    # Deploy with parameter file
    $0 -g my-rg -p parameters.json

    # Dry run (validation only)
    $0 -g my-rg -d

    # Create resource group and deploy
    $0 -g my-new-rg -l eastus -c

EOF
}

check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Bicep template exists
    if [[ ! -f "$BICEP_FILE" ]]; then
        error "Bicep template not found: $BICEP_FILE"
        exit 1
    fi
    
    # Check Azure CLI login status
    if ! az account show &> /dev/null; then
        error "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    
    success "Prerequisites check passed"
}

validate_parameters() {
    log "Validating parameters..."
    
    if [[ -z "$RESOURCE_GROUP" ]]; then
        error "Resource group is required. Use -g or --resource-group"
        exit 1
    fi
    
    if [[ -n "$PARAMETER_FILE" && ! -f "$PARAMETER_FILE" ]]; then
        error "Parameter file not found: $PARAMETER_FILE"
        exit 1
    fi
    
    if [[ -n "$SECRET_FILE" && ! -f "$SECRET_FILE" ]]; then
        error "Secret file not found: $SECRET_FILE"
        exit 1
    fi
    
    success "Parameter validation passed"
}

set_subscription() {
    if [[ -n "$SUBSCRIPTION_ID" ]]; then
        log "Setting subscription to: $SUBSCRIPTION_ID"
        az account set --subscription "$SUBSCRIPTION_ID"
    fi
    
    local current_sub
    current_sub=$(az account show --query id -o tsv)
    log "Using subscription: $current_sub"
}

create_resource_group_if_needed() {
    if [[ "$CREATE_RESOURCE_GROUP" == "true" ]]; then
        log "Checking if resource group exists: $RESOURCE_GROUP"
        
        if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
            log "Creating resource group: $RESOURCE_GROUP in $LOCATION"
            az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
            success "Resource group created successfully"
        else
            log "Resource group already exists: $RESOURCE_GROUP"
        fi
    else
        # Verify resource group exists
        if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
            error "Resource group '$RESOURCE_GROUP' does not exist. Use -c to create it."
            exit 1
        fi
    fi
}

get_current_user_object_id() {
    local object_id
    object_id=$(az ad signed-in-user show --query id -o tsv 2>/dev/null || echo "")
    
    if [[ -n "$object_id" ]]; then
        log "Current user object ID: $object_id" >&2
        echo "$object_id"
    else
        warning "Could not retrieve current user object ID" >&2
        echo ""
    fi
}

build_deployment_parameters() {
    local params_json="{"
    local has_params=false
    
    # Add location
    params_json="$params_json\"location\":{\"value\":\"$LOCATION\"}"
    has_params=true
    
    # Add environment tag
    if [[ "$has_params" == "true" ]]; then
        params_json="$params_json,"
    fi
    params_json="$params_json\"tags\":{\"value\":{\"Environment\":\"$ENVIRONMENT\",\"DeployedBy\":\"$(whoami)\",\"DeployedAt\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}}"
    
    # Add current user as principal ID for RBAC
    local current_user_id
    current_user_id=$(get_current_user_object_id)
    if [[ -n "$current_user_id" && "$current_user_id" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
        params_json="$params_json,\"principalId\":{\"value\":\"$current_user_id\"}"
        log "Using principal ID: $current_user_id" >&2
    else
        warning "Invalid or missing current user object ID, RBAC roles will not be assigned" >&2
    fi
    
    # Add secret file if provided
    if [[ -n "$SECRET_FILE" ]]; then
        local secret_content
        secret_content=$(cat "$SECRET_FILE")
        params_json="$params_json,\"createSampleSecrets\":{\"value\":true},\"sampleSecretValue\":{\"value\":\"$secret_content\"}"
    fi
    
    # Enable public access for development environment and use standard SKU
    if [[ "$ENVIRONMENT" == "dev" || "$ENVIRONMENT" == "development" ]]; then
        params_json="$params_json,\"publicNetworkAccess\":{\"value\":\"Enabled\"},\"skuName\":{\"value\":\"standard\"}"
    fi
    
    params_json="$params_json}"
    echo "$params_json"
}

run_what_if() {
    if [[ "$SKIP_WHAT_IF" == "true" ]]; then
        log "Skipping what-if analysis"
        return
    fi
    
    log "Running what-if analysis..."
    
    local params
    params=$(build_deployment_parameters)
    
    local what_if_args=(
        --resource-group "$RESOURCE_GROUP"
        --template-file "$BICEP_FILE"
        --parameters "$params"
        --name "$DEPLOYMENT_NAME"
    )
    
    if [[ "$VERBOSE" == "true" ]]; then
        what_if_args+=(--verbose)
    fi
    
    # Add parameter file if specified
    if [[ -n "$PARAMETER_FILE" ]]; then
        what_if_args+=(--parameters "@$PARAMETER_FILE")
    fi
    
    if az deployment group what-if "${what_if_args[@]}"; then
        success "What-if analysis completed successfully"
        
        # Ask for confirmation unless it's a dry run
        if [[ "$DRY_RUN" == "false" ]]; then
            echo
            read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log "Deployment cancelled by user"
                exit 0
            fi
        fi
    else
        error "What-if analysis failed"
        exit 1
    fi
}

deploy_template() {
    if [[ "$DRY_RUN" == "true" ]]; then
        success "Dry run completed successfully"
        return
    fi
    
    log "Starting deployment: $DEPLOYMENT_NAME"
    
    local params
    params=$(build_deployment_parameters)
    
    local deploy_args=(
        --resource-group "$RESOURCE_GROUP"
        --template-file "$BICEP_FILE"
        --parameters "$params"
        --name "$DEPLOYMENT_NAME"
        --mode Incremental
    )
    
    if [[ "$VERBOSE" == "true" ]]; then
        deploy_args+=(--verbose)
    fi
    
    # Add parameter file if specified
    if [[ -n "$PARAMETER_FILE" ]]; then
        deploy_args+=(--parameters "@$PARAMETER_FILE")
    fi
    
    log "Deployment parameters:"
    echo "$params" | jq . || echo "$params"
    
    if az deployment group create "${deploy_args[@]}"; then
        success "Deployment completed successfully!"
        
        # Show deployment outputs
        log "Retrieving deployment outputs..."
        az deployment group show \
            --resource-group "$RESOURCE_GROUP" \
            --name "$DEPLOYMENT_NAME" \
            --query properties.outputs \
            --output table
            
    else
        error "Deployment failed"
        exit 1
    fi
}

cleanup_on_error() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        error "Script failed with exit code: $exit_code"
        
        if [[ "$DRY_RUN" == "false" && -n "$RESOURCE_GROUP" ]]; then
            log "Checking deployment status..."
            az deployment group show \
                --resource-group "$RESOURCE_GROUP" \
                --name "$DEPLOYMENT_NAME" \
                --query properties.provisioningState \
                --output tsv 2>/dev/null || true
        fi
    fi
}

# =============================================================================
# Main Script Logic
# =============================================================================

# Set up error handling
trap cleanup_on_error EXIT

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -s|--subscription)
            SUBSCRIPTION_ID="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -p|--parameters)
            PARAMETER_FILE="$2"
            shift 2
            ;;
        -f|--secret-file)
            SECRET_FILE="$2"
            shift 2
            ;;
        -n|--deployment-name)
            DEPLOYMENT_NAME="$2"
            shift 2
            ;;
        -c|--create-resource-group)
            CREATE_RESOURCE_GROUP=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -w|--skip-what-if)
            SKIP_WHAT_IF=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    log "Starting General Purpose Key Vault deployment script"
    log "Deployment name: $DEPLOYMENT_NAME"
    
    check_prerequisites
    validate_parameters
    set_subscription
    create_resource_group_if_needed
    run_what_if
    deploy_template
    
    success "Script completed successfully!"
}

# Run main function
main "$@"
