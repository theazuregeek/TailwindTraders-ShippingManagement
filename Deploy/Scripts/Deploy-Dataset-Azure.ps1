#! /usr/bin/pwsh

Param(
    [parameter(Mandatory=$true)][string]$resourceGroup,
    [parameter(Mandatory=$true)][string]$storageName,
    [parameter(Mandatory=$true)][string]$containerName,
    [parameter(Mandatory=$true)][string]$containerNameProducts
)

$storage = $(az storage account show -n $storageName -g $resourceGroup -o json | ConvertFrom-Json)

if (-not $storage) {
    Write-Host "Storage $storageName not found in RG $resourceGroup" -ForegroundColor Red
    exit 1
}

$container = $(az storage container exists --account-name $storageName --name $containerName)

if (-not $container) {
    Write-Host "Creating container $containerName in storage $storageName" -ForegroundColor Yellow
    az storage container create --account-name $storageName --name $containerName
    Write-Host "Container created"
}

$urlBlbsContainer = $storage.primaryEndpoints.blob + $containerName;
$urlBlbsContainerProducts = $storage.primaryEndpoints.blob + $containerNameProducts;

$accountName=$storage.name

Push-Location $($MyInvocation.InvocationName | Split-Path)
Push-Location ..

Write-Host "Uploading images to $containerName" -ForegroundColor Yellow
az storage blob upload-batch --destination "$urlBlbsContainer" --source $(Join-Path tailwindtraders-files form-recognized-dataset) --account-name $storageName
Write-Host "Images uploaded..."

Write-Host "Uploading images to $containerNameProducts" -ForegroundColor Yellow
az storage blob upload-batch --destination "$urlBlbsContainerProducts" --source $(Join-Path tailwindtraders-files tailwindtraders-products) --account-name $storageName
Write-Host "Images uploaded..."

Pop-Location
Pop-Location
