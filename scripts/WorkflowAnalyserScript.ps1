Param (
  [string] $ProjectFilePath= "", #reference to the JSON
  [string] $destination_folder = "" #location of the analisis file
)

function WriteLog
{
	Param ($message, [switch] $err)
	
	$now = Get-Date -Format "G"
	$line = "$now`t$message"
	$line | Add-Content $debugLog -Encoding UTF8
	if ($err)
	{
		Write-Host $line -ForegroundColor red
	} else {
		Write-Host $line
	}
}
$debugLog = "$scriptPath\orchestrator-package-pack.log"

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$uipathCLI = "$scriptPath\uipathcli\lib\net461\uipcli.exe"
if (-not(Test-Path -Path $uipathCLI -PathType Leaf)) {
    WriteLog "UiPath CLI does not exist in this folder. Attempting to download it..."
    try {
        New-Item -Path "$scriptPath" -ItemType "directory" -Name "uipathcli";
        Invoke-WebRequest "https://www.myget.org/F/uipath-dev/api/v2/package/UiPath.CLI/1.0.7802.11617" -OutFile "$scriptPath\\uipathcli\\cli.zip";
        Expand-Archive -LiteralPath "$scriptPath\\uipathcli\\cli.zip" -DestinationPath "$scriptPath\\uipathcli";
        WriteLog "UiPath CLI is downloaded and extracted in folder $scriptPath\\uipathcli"
        if (-not(Test-Path -Path $uipathCLI -PathType Leaf)) {
            WriteLog "Unable to locate uipath cli after it is downloaded."
            exit 1
        }
    }
    catch {
        WriteLog ("Error Occured : " + $_.Exception.Message) -err $_.Exception
        exit 1
    }
    
}
WriteLog "-----------------------------------------------------------------------------"
WriteLog "uipcli location :   $uipathCLI"

$OutputFilePath = Join-Path -Path $destination_folder -ChildPath Workflow-Analysis.json
WriteLog "Output File Path : $OutputFilePath"

Write-Output "$(Get-Date -Format 'HH:mm:ss') - STARTED - Workflow Analyzer CLI Script"
$Command = "$scriptPath analyze -p $ProjectFilePath"
Invoke-Expression $Command | Out-File -FilePath $OutputFilePath

Write-Output "$(Get-Date -Format 'HH:mm:ss') - COMPLETED - Workflow analyzer CLI Script to $OutputFilePath"
