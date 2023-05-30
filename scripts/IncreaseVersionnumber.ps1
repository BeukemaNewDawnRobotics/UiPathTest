Param (

    #Required
	[string] $json_path = "" # Required. The path to a json.
)


$pathToJson = 'project.json'
$a = Get-Content 'project.json' -raw | ConvertFrom-Json
$version = [version]($a).projectVersion
$newVersion = "{0}.{1}.{2}" -f $version.Major, $version.Minor, ($version.Build+1)
Write-Host "Versie " $version " verhoogd naar " $newVersion
$a.projectVersion=$newVersion
$a | ConvertTo-Json -Depth 4| set-content $pathToJson 
Write-Host "Nieuwe versie weggeschreven in de JSON"
