cd "C:\Test\UiPathTest\"
#Read Workflow Analysis JSON
$JSONObject = ((Get-Content -Raw 'Workflow-Analysis.json') -replace "#json", "" | ConvertFrom-Json)

#Transform the given JSON into a right formatted JSON
$JSONObjectGeordend = @{}
$array = @()
$data = @{}

foreach( $Propertie in $JSONInput.PsObject.Properties)
{
    $Keyvalue = $Propertie.Name.split("-")[5]
    $ErrorNumber = $Propertie.Name.Substring(0,36)
    #write-output "Name: $($Propertie.Name) Value: $($Propertie.Value)"
    #write-output $Keyvalue
    if ($data.Count -gt 0 -AND $Keyvalue -eq "FilePath"){
        $array += $data #Add collected data to array
        $data = @{} #Reset the data variable   
    } 
    $data.Add($Keyvalue,$Propertie.Value) #add current item info to the data variable
}

#When done add the array to the new JSON
$JSONObjectGeordend.Add("Fouten", $array)

#Convert and Export JSON
$JSONStringOutput = $JSONJuist | ConvertTo-Json
$JSONStringOutput | Out-File ".\WorkflowAnalyserConverted.json"



#Transform data to a table to display information
$table = @()

$JSONObjectGeordend.Fouten | ForEach-Object {
    $Fout = $_
    $row = New-Object -TypeName PSObject
    $row | Add-Member -MemberType NoteProperty -Name "ErrorSeverity" -Value $Fout.ErrorSeverity
    $row | Add-Member -MemberType NoteProperty -Name "ErrorCode" -Value $Fout.ErrorCode
    $row | Add-Member -MemberType NoteProperty -Name "FilePath" -Value $Fout.FilePath
    $row | Add-Member -MemberType NoteProperty -Name "Description" -Value $Fout.Description
    $table += $row
}


#Collect information and display
#Count the Errors based on the Severity
$ErrorSeverityList = "Info", "Warning", "Error", "Verbose"  # All possible ErrorSeverity values

    $ErrorSeverityTable = $ErrorSeverityList | ForEach-Object {
        $ErrorSeverity = $_
        $group = $table | Where-Object { $_.ErrorSeverity -eq $ErrorSeverity } #find all the values with this severity

        if ($group) {
            $count = $group.Count #count the results
        } else {
            $count = 0 #if none is found the count is 0
        }

        [PSCustomObject]@{
            ErrorSeverity = $ErrorSeverity
            Count = $count    
        }
    }

# Define the custom ordering for ErrorSeverity
$customOrder = @{
    "Info" = 4
    "Warning" = 3
    "Error" = 2
    "Verbose" = 1
}

# Display the ErrorSeverity table
$ErrorSeverityTable = $ErrorSeverityTable | Sort-Object -Property {$customOrder[$_.ErrorSeverity]}
Write-Host "Count of the Errors by Severity"
$ErrorSeverityTable | Format-Table -AutoSize

# Group the table by ErrorCode
$GroupErrorCodeTable = $table | Group-Object -Property ErrorCode

# Create a grouped table with a count
$ErrorCodeTable = $GroupErrorCodeTable | ForEach-Object {
    $group = $_
    $ErrorCode = $group.Group[0].ErrorCode
    $count = $group.Count

    [PSCustomObject]@{
        ErrorCode = $ErrorCode
        Count = $count
        
    }
}
# Display the grouped table
$ErrorCodeTable = $ErrorCodeTable | Sort-Object -Property @{Expression="Count"; Descending=$true}, @{Expression="ErrorCode"; Ascending=$true}
Write-Host "Count of the Errors by ErrorCode"
$ErrorCodeTable | Format-Table -AutoSize



# Group the table by FilePath, ErrorSeverity, and Description
$groupedTable = $table | Group-Object -Property ErrorSeverity, FilePath, ErrorCode, Description

# Create a grouped table with a count
$tableGrouped = $groupedTable | ForEach-Object {
    $group = $_
    $filePath = $group.Group[0].FilePath
    if ([string]::IsNullOrEmpty($filePath)) {
        $filePath = " General error"
    }
    $errorSeverity = $group.Group[0].ErrorSeverity
    $errorCode = $group.Group[0].ErrorCode
    $Description = $group.Group[0].Description
    $count = $group.Count

    [PSCustomObject]@{
        FilePath = $filePath
        ErrorCode = $errorCode
        ErrorSeverity = $errorSeverity
        Count = $count
        Description = $Description
    }
}

# Display the grouped table
Write-Host "Table with an overview of the Errors group by FilePath"
$tableGrouped = $tableGrouped | Sort-Object -Property  FilePath, {$customOrder[$_.ErrorSeverity]}
$tableGrouped | Format-Table -AutoSize


