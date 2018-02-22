﻿param (
[Parameter(Mandatory=$false, HelpMessage='Major, Minor, or Patch?')][ValidateSet('Major','Minor', 'Patch')][string]$releaseType
)

function Get-ReleaseType { 
    $title    = 'Releasing project'
    $message  = 'What type of release are you making?'

    $majorRelease = New-Object System.Management.Automation.Host.ChoiceDescription '&1 Major', `
    'Choose Major for huge breaking changes.'

    $minorRelease = New-Object System.Management.Automation.Host.ChoiceDescription '&2 Minor', `
    'Choose Minor for new functionality or small changes.'

    $patchRelease = New-Object System.Management.Automation.Host.ChoiceDescription '&3 Patch', `
    'Choose Patch for bugfixes.'

    $options  = [System.Management.Automation.Host.ChoiceDescription[]]($majorRelease, $minorRelease, $patchRelease)

    $result   = $host.ui.PromptForChoice($title, $message, $options, 2) 

    switch ($result)
    {
        0 {Write-Output 'Major'}
        1 {Write-Output 'Minor'}
        2 {Write-Output 'Patch'}
    }
}


  #Calling the Get-ProjectType if it is missing
    if(!$releaseType) {
        $releaseType = Get-ReleaseType
    }

Push-Location $PSScriptRoot

$fileName = Get-ChildItem -Filter "build.xml" -Recurse
$xmlDoc = [System.Xml.XmlDocument](Get-Content $fileName.FullName)

$node = $xmlDoc.Project.PropertyGroup.ChildNodes
foreach($properties in $node)
{
    if ($properties.Name -eq "VersionMajor") 
    {
        $majorNumber = [int]$properties.'#text'
        if($releaseType -eq "Major")
        {
            $majorNumber = $majorNumber + 1
            $properties.set_InnerXML($majorNumber) 

            $minorNumber = 0
            $patchNumber = 0
        }
      

    }
    if ($properties.Name -eq "VersionMinor") 
    {
        $minorNumber = [int]$properties.'#text'

        if($releaseType -eq "Minor")
        {
            $minorNumber = $minorNumber + 1

            $patchNumber = 0
        } 
      
        if($minorNumber)
        {
            $properties.set_InnerXML($minorNumber) 
        }
    }
    if ($properties.Name -eq "VersionPatch") 
    {
        if($releaseType -eq "Patch")
        {
            $patchNumber = [int]$properties.'#text'
            $patchNumber = $patchNumber + 1
        }
      
        if($patchNumber)
        {
            $properties.set_InnerXML($patchNumber) 
        }
    }
}

# Save File
$xmlDoc.Save($fileName.FullName)

$newAssemblyInfoPath = "$majorNumber.$minorNumber.$patchNumber"


& $env:windir\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe build.xml


#& .\nuget.exe push "package/SiteImprove.EPiServer.Plugin.$newAssemblyInfoPath.nupkg"  -Source http://nuget.nmester.dk:3311/api
