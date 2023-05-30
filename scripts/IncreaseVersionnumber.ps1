Param (

    #Required
	[string] $json_path = "" # Required. The path to a json.
)


$pathToJson = 'project.json'
$a = Get-Content 'project.json' -raw | ConvertFrom-Json
$version = [version]($a).projectVersion
Write-Host "Versie " $version " verhoogd naar " $newVersion
$newVersion = "{0}.{1}.{2}" -f $version.Major, $version.Minor, ($version.Build+1)
$a.projectVersion=$newVersion
$a | ConvertTo-Json | set-content $pathToJson
Write-Host "Nieuwe versie weggeschreven in de JSON"
