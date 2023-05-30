$pathToJson = 'project.json'
$a = Get-Content 'project.json' -raw | ConvertFrom-Json
$version = [version]($a).projectVersion
$newVersion = "{0}.{1}.{2}" -f $version.Major, $version.Minor, ($version.Build+1)
$a.projectVersion=$newVersion
$a | ConvertTo-Json | set-content $pathToJson
