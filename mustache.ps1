
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

$SystemDifinition = ConvertFrom-MustacheTemplate -Template $SystemsDifinitionFile -Values $ConvertTypeTable

$Source = Get-Content -Path .\static-ecs.fs.template

ConvertFrom-MustacheTemplate -Template $Source -Values $SystemDifinition
