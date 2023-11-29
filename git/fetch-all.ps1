<#
.SYNOPSIS
Recusively perform `git fetch` from the current directory.

.DESCRIPTION
From the current directory, perform `git fetch` in directories that contain a git repository.

.PARAMETER WhatIf
Enables the `--dry-run` flag in `git fetch`.

.PARAMETER Verbose
Enables the `--verbose` and `--progress` flags in `git fetch` and displays the path for each invocation of `git fetch`.

.PARAMETER Quiet
Enables the `--quite` flag in `git fetch`.

.INPUTS
None. You can't pipe objects to fetch-all.

.OUTPUTS
System.String. Output from `git` is output by this script.

.EXAMPLE
PR> fetch-all.ps1

.EXAMPLE
PR> fetch-all.ps1 -Verbose

#>

using namespace System.IO;
param (
    [switch]$WhatIf,
    [switch]$Verbose,
    [switch]$Quiet
    )
$currentDir = (get-location).Path;

if($Verbose.IsPresent) {
    $VerbosePreference = "Continue";
}

function Build-Command {
    $expression = 'git fetch';
    if($Quiet.IsPresent) {
        $expression += ' -q';
    }
    if($Verbose.IsPresent) {
        $expression += ' -v --progress';
    }
    if($WhatIf.IsPresent) {
        $expression += ' --dry-run';
    }
    $expression += " origin";
    return $expression;
}

# `System.IO.Directory.GetDirectories(...[SearchOption]::AllDirectories)` is much faster in PowerShell than `Get-ChildItem -Directory -r`
foreach($item in $([Directory]::GetDirectories($currentDir, '.git', [SearchOption]::AllDirectories);)) {
    $dir = get-item -Force $item;
    Push-Location $dir.Parent;
    try {
        Write-Verbose "fetching in $((Get-Location).Path)...";
        $expression = Build-Command;

        Invoke-expression $expression;

    } finally {
        Pop-Location;
    }
}