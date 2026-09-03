# ============================================
# Generate terraform.tfvars from detail.csv
# ============================================

Write-Host ""
Write-Host "======================================"
Write-Host "CSV TO TERRAFORM.TFVARS GENERATOR"
Write-Host "======================================"

# ============================================
# Current Terraform Directory
# ============================================

$TerraformPath = $PSScriptRoot

$CsvFile = Join-Path $TerraformPath "detail.csv"
$TfVarsFile = Join-Path $TerraformPath "terraform.tfvars"


Write-Host ""
Write-Host "Terraform Directory:"
Write-Host $TerraformPath

Write-Host ""
Write-Host "CSV File:"
Write-Host $CsvFile

Write-Host ""
Write-Host "Terraform Variables File:"
Write-Host $TfVarsFile


# ============================================
# Check CSV File
# ============================================

Write-Host ""
Write-Host "======================================"
Write-Host "Checking CSV File"
Write-Host "======================================"

if (-not (Test-Path -LiteralPath $CsvFile)) {

    Write-Error "CSV file not found: $CsvFile"
    exit 1
}

Write-Host "CSV file found successfully."


# ============================================
# Read CSV
# ============================================

Write-Host ""
Write-Host "======================================"
Write-Host "Reading Customer CSV"
Write-Host "======================================"

try {

    $Data = @(Import-Csv -LiteralPath $CsvFile)

}
catch {

    Write-Error "Failed to read CSV file."
    Write-Error $_
    exit 1
}


# ============================================
# Check CSV Data
# ============================================

if ($Data.Count -eq 0) {

    Write-Error "CSV file is empty."
    exit 1
}

Write-Host "Total records found: $($Data.Count)"


# ============================================
# Validate CSV Columns
# ============================================

Write-Host ""
Write-Host "======================================"
Write-Host "Validating CSV"
Write-Host "======================================"

$RequiredColumns = @(
    "name",
    "location"
)

foreach ($Column in $RequiredColumns) {

    if ($null -eq $Data[0].PSObject.Properties[$Column]) {

        Write-Error "Required column '$Column' not found in CSV."
        exit 1
    }
}

Write-Host "CSV columns are valid."


# ============================================
# Generate Terraform HCL
# ============================================

Write-Host ""
Write-Host "======================================"
Write-Host "Generating Terraform Variables"
Write-Host "======================================"

$TerraformContent = @"
rgs = {

"@


foreach ($Row in $Data) {

    # ----------------------------------------
    # Validate Name
    # ----------------------------------------

    if ([string]::IsNullOrWhiteSpace($Row.name)) {

        Write-Error "Resource group name cannot be empty."
        exit 1
    }


    # ----------------------------------------
    # Validate Location
    # ----------------------------------------

    if ([string]::IsNullOrWhiteSpace($Row.location)) {

        Write-Error "Location cannot be empty for resource group '$($Row.name)'."
        exit 1
    }


    # ----------------------------------------
    # Add Terraform Resource Group
    # ----------------------------------------

    $TerraformContent += @"
  $($Row.name) = {
    name     = "$($Row.name)"
    location = "$($Row.location)"
  }

"@

}


# ============================================
# Close Terraform Map
# ============================================

$TerraformContent += "}`r`n"


# ============================================
# Write terraform.tfvars
# ============================================

Write-Host ""
Write-Host "======================================"
Write-Host "Creating terraform.tfvars"
Write-Host "======================================"

try {

    Set-Content `
        -LiteralPath $TfVarsFile `
        -Value $TerraformContent `
        -Encoding UTF8

}
catch {

    Write-Error "Failed to create terraform.tfvars."
    Write-Error $_
    exit 1
}


# ============================================
# Verify File
# ============================================

if (-not (Test-Path -LiteralPath $TfVarsFile)) {

    Write-Error "terraform.tfvars was not created."
    exit 1
}


# ============================================
# Display Result
# ============================================

Write-Host ""
Write-Host "======================================"
Write-Host "GENERATED terraform.tfvars"
Write-Host "======================================"

Get-Content -LiteralPath $TfVarsFile


# ============================================
# Success
# ============================================

Write-Host ""
Write-Host "======================================"
Write-Host "SUCCESS"
Write-Host "======================================"

Write-Host "terraform.tfvars generated successfully."

Write-Host ""
Write-Host "File location:"
Write-Host $TfVarsFile

Write-Host ""
Write-Host "======================================"