
param(
    [Parameter(Mandatory=$true)]
    [string]$Path,

    [Parameter(Mandatory=$true)]
    [string]$Language
)

enum Language {
    cs
    fs
    rust
}

$Language = [Language]$Language

$ConvertTypeTable = Get-Content -Path .\convert-type-$Language.yaml -Raw | ConvertFrom-Yaml

$SystemsDifinitionFile = Get-Content -Path $Path -Raw

$BaseDifinition = ConvertFrom-MustacheTemplate -Template $SystemsDifinitionFile -Values $ConvertTypeTable | ConvertFrom-Yaml

$Source = Get-Content -Path .\static-ecs.fs.template -Raw

# echo $SystemDifinition.Components.GetType()

$SystemDifinition = @{}
$SystemDifinition.Components = $BaseDifinition.Components.Keys #[System.Collections.Generic.List[string]]::new()

$SystemDifinition.ValueComponents = $BaseDifinition.Components.GetEnumerator()
 | Where-Object { $_.Value -is [string] }
 | ForEach-Object { @{ Name=$_.Key; Content=$_.Value} }

$SystemDifinition.StructComponents = $BaseDifinition.Components.GetEnumerator()
 | Where-Object { $_.Value -is [hashtable] }
 | ForEach-Object { @{ Name=$_.Key; Content=$_.Value} }

# echo $SystemDifinition.ValueComponents

ConvertFrom-MustacheTemplate -Template $Source -Values $SystemDifinition
