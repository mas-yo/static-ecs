
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

function ConvertType($tp) {
    $ConvertTypeTable[$tp]
}

function ConvertToNameAndType($kv) {
    @{ Name=$kv.Key; Type=ConvertType($kv.Value) }
}

$Language = [Language]$Language

$ConvertTypeTable = Get-Content -Path .\convert-type-$Language.yaml -Raw | ConvertFrom-Yaml

$BaseDifinition = Get-Content -Path $Path -Raw | ConvertFrom-Yaml

$Source = Get-Content -Path .\static-ecs.fs.template -Raw

# echo $SystemDifinition.Components.GetType()

$SystemDifinition = @{}
$SystemDifinition.Components = $BaseDifinition.Components.Keys

$SystemDifinition.ValueComponents = $BaseDifinition.Components.GetEnumerator()
 | Where-Object { $_.Value -is [string] }
 | ForEach-Object { ConvertToNameAndType $_ }

$SystemDifinition.StructComponents = $BaseDifinition.Components.GetEnumerator()
 | Where-Object { $_.Value -is [hashtable] }
 | ForEach-Object { @{ Name=$_.Key; Fields=($_.Value.GetEnumerator() | ForEach-Object { ConvertToNameAndType $_ }) } }

# echo $SystemDifinition.ValueComponents

ConvertFrom-MustacheTemplate -Template $Source -Values $SystemDifinition
