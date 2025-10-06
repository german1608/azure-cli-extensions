#!/bin/bash

# Azure Resource Provisioning Script
# This script provisions a resource group and a storage account

set -e  # Exit on any error

# Default configuration
DEFAULT_RESOURCE_GROUP="applink-private-az-cli"
DEFAULT_LOCATION="eastus"
DEFAULT_STORAGE_ACCOUNT="applinkteststorage"
DEFAULT_SKU="Standard_LRS"
DEFAULT_KIND="StorageV2"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

This script provisions an Azure resource group and storage account.

OPTIONS:
    -g, --resource-group    Resource group name (default: $DEFAULT_RESOURCE_GROUP)
    -l, --location         Azure region (default: $DEFAULT_LOCATION)
    -s, --storage-account  Storage account name (default: auto-generated)
    --sku                  Storage account SKU (default: $DEFAULT_SKU)
    --kind                 Storage account kind (default: $DEFAULT_KIND)
    -h, --help             Show this help message
    --dry-run              Show what would be created without actually creating resources

EXAMPLES:
    $0
    $0 -g my-resource-group -l westus2
    $0 --storage-account mystorageaccount --sku Standard_GRS
    $0 --dry-run

EOF
}

# Parse command line arguments
RESOURCE_GROUP="$DEFAULT_RESOURCE_GROUP"
LOCATION="$DEFAULT_LOCATION"
STORAGE_ACCOUNT="$DEFAULT_STORAGE_ACCOUNT"
SKU="$DEFAULT_SKU"
KIND="$DEFAULT_KIND"
DRY_RUN=false

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
        -s|--storage-account)
            STORAGE_ACCOUNT="$2"
            shift 2
            ;;
        --sku)
            SKU="$2"
            shift 2
            ;;
        --kind)
            KIND="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Function to check if Azure CLI is installed and user is logged in
check_prerequisites() {
    print_info "Checking prerequisites..."

    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        print_info "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi

    # Check if user is logged in
    if ! az account show &> /dev/null; then
        print_error "You are not logged in to Azure. Please run 'az login' first."
        exit 1
    fi

    # Get current subscription info
    SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)

    print_success "Azure CLI is installed and you are logged in"
    print_info "Current subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"
}

# Function to validate storage account name
validate_storage_account_name() {
    local name="$1"

    # Storage account name must be 3-24 characters long and contain only lowercase letters and numbers
    if [[ ! "$name" =~ ^[a-z0-9]{3,24}$ ]]; then
        print_error "Storage account name '$name' is invalid."
        print_error "Storage account names must be 3-24 characters long and contain only lowercase letters and numbers."
        exit 1
    fi
}

# Function to check if resource group exists
check_resource_group() {
    local rg_name="$1"

    if az group show --name "$rg_name" &> /dev/null; then
        return 0  # exists
    else
        return 1  # doesn't exist
    fi
}

# Function to check if storage account exists
check_storage_account() {
    local storage_name="$1"

    if az storage account show --name "$storage_name" &> /dev/null 2>&1; then
        return 0  # exists
    else
        return 1  # doesn't exist
    fi
}

# Function to create resource group
create_resource_group() {
    local rg_name="$1"
    local location="$2"

    if check_resource_group "$rg_name"; then
        print_warning "Resource group '$rg_name' already exists. Skipping creation."
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would create resource group: $rg_name in $location"
        return 0
    fi

    print_info "Creating resource group: $rg_name in $location"

    if az group create --name "$rg_name" --location "$location" --output none; then
        print_success "Resource group '$rg_name' created successfully"
    else
        print_error "Failed to create resource group '$rg_name'"
        exit 1
    fi
}

# Function to create storage account
create_storage_account() {
    local storage_name="$1"
    local rg_name="$2"
    local location="$3"
    local sku="$4"
    local kind="$5"

    if check_storage_account "$storage_name"; then
        print_warning "Storage account '$storage_name' already exists. Skipping creation."
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would create storage account: $storage_name"
        print_info "[DRY RUN]   Resource group: $rg_name"
        print_info "[DRY RUN]   Location: $location"
        print_info "[DRY RUN]   SKU: $sku"
        print_info "[DRY RUN]   Kind: $kind"
        return 0
    fi

    print_info "Creating storage account: $storage_name"
    print_info "  Resource group: $rg_name"
    print_info "  Location: $location"
    print_info "  SKU: $sku"
    print_info "  Kind: $kind"

    if az storage account create \
        --name "$storage_name" \
        --resource-group "$rg_name" \
        --location "$location" \
        --sku "$sku" \
        --kind "$kind" \
        --output none; then
        print_success "Storage account '$storage_name' created successfully"
    else
        print_error "Failed to create storage account '$storage_name'"
        exit 1
    fi
}

# Function to display summary
show_summary() {
    echo ""
    print_success "=== RESOURCE PROVISIONING SUMMARY ==="
    echo "Resource Group: $RESOURCE_GROUP"
    echo "Location: $LOCATION"
    echo "Storage Account: $STORAGE_ACCOUNT"
    echo "Storage SKU: $SKU"
    echo "Storage Kind: $KIND"
    echo "Subscription: $SUBSCRIPTION_NAME"

    if [[ "$DRY_RUN" == "false" ]]; then
        echo ""
        print_info "You can now use these resources for your AppLink testing."
        print_info "To clean up resources later, run:"
        echo "  az group delete --name $RESOURCE_GROUP --yes --no-wait"
    fi
}

# Main execution
main() {
    echo "=== Azure Resource Provisioning Script ==="
    echo ""

    # Check prerequisites
    check_prerequisites

    # Validate storage account name
    validate_storage_account_name "$STORAGE_ACCOUNT"

    # Show what will be created
    echo ""
    print_info "Configuration:"
    echo "  Resource Group: $RESOURCE_GROUP"
    echo "  Location: $LOCATION"
    echo "  Storage Account: $STORAGE_ACCOUNT"
    echo "  Storage SKU: $SKU"
    echo "  Storage Kind: $KIND"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN MODE - No resources will be created"
    fi

    echo ""

    # Create resources
    create_resource_group "$RESOURCE_GROUP" "$LOCATION"
    create_storage_account "$STORAGE_ACCOUNT" "$RESOURCE_GROUP" "$LOCATION" "$SKU" "$KIND"

    # Show summary
    show_summary
}

# Run main function
main "$@"