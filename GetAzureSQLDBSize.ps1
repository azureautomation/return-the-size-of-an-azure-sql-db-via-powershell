#Start Script 
$SubscriptionID = "{Subscription GUID}"
$ResourceGroup = "{Resource Group Name}"
$ServerName = "{SQL Server Name}"
$DBName = "{Database Name Here}"

$Subscription = Get-AzureRmSubscription -SubscriptionId $SubscriptionID

# Load ADAL Azure AD Authentication Library Assemblies
$adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
$adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
$null = [System.Reflection.Assembly]::LoadFrom($adal)
$null = [System.Reflection.Assembly]::LoadFrom($adalforms)

$adTenant = $Subscription.TenantId
$global:SubscriptionID = $Subscription.SubscriptionId

# Client ID for Azure PowerShell
$clientId = "1950a258-227b-4e31-a9cf-717495945fc2"
# Set redirect URI for Azure PowerShell
$redirectUri = "urn:ietf:wg:oauth:2.0:oob"
# Set Resource URI to Azure Service Management API | @marckean
$resourceAppIdURIASM = "https://management.core.windows.net/"
$resourceAppIdURIARM = "https://management.azure.com/"

# Authenticate and Acquire Token

# Set Authority to Azure AD Tenant
$authority = "https://login.windows.net/$adTenant"
# Create Authentication Context tied to Azure AD Tenant
$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
# Acquire token
$global:authResultASM = $authContext.AcquireToken($resourceAppIdURIASM, $clientId, $redirectUri, "Auto")
$global:authResultARM = $authContext.AcquireToken($resourceAppIdURIARM, $clientId, $redirectUri, "Auto")

$authHeader = $global:authResultARM.CreateAuthorizationHeader()
$requestHeader = @{
"x-ms-version" = "2014-10-01"; #'2014-10-01'
"Authorization" = $authHeader
}

$URL = "https://management.azure.com/subscriptions/$($Subscription.SubscriptionId)/resourceGroups/$($ResourceGroup)/providers/Microsoft.Sql/servers/$($ServerName)/databases/$($DBName)/usages?api-version=2014-04-01-preview"

$rResponse = Invoke-WebRequest $URL -Headers $requestHeader
$jResponse = $bResponse.Content | ConvertFrom-Json

Write-Output "Server: $($ServerName)"
Write-Output "Database: $($DBName)"
Write-Output "$($jResponse.value.currentValue) $($jResponse.value.unit)"
#End Script 
