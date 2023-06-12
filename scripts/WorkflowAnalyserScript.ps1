param(
$ProjectFilePath="C:\Test\UiPathTest\project.json",
$ExecutableFilePath="C:\Users\SanderBeukema\AppData\Local\Programs\UiPath\Studio\UiPath.Studio.CommandLine.exe",
$OutputFilePath="C:\Test\UiPathTest\Workflow-Analysis.json"
)

Write-Output "$(Get-Date -Format 'HH:mm:ss') - STARTED - Workflow Analyzer CLI Script"
$Command = "$ExecutablefilePath analyze -p $ProjectFilePath"
Invoke-Expression $Command | Out-File -FilePath $OutputFilePath

Write-Output "$(Get-Date -Format 'HH:mm:ss') - COMPLETED - Workflow analyzer CLI Script to $OutputFilePath"