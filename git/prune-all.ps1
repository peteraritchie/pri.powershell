<#
.SYNOPSIS
Recusively perform `git remote prune` from the current directory.

.DESCRIPTION
From the current directory, perform `git remote prune` in directories that contain a git repository.

.PARAMETER WhatIf
Enables the `--dry-run` flag in `git remote prune`.

.PARAMETER Verbose
Enables the `--verbose` and `--progress` flags in `git remote prune` and displays the path for each invocation of `git remote prune`.

.PARAMETER Quiet
Enables the `--quite` flag in `git remote prune`.

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
    [switch]$Verbose
    )
$currentDir = (get-location).Path;

if($Verbose.IsPresent) {
    $VerbosePreference = "Continue";
}

function Build-Command {
    $expression = 'git remote';
    if($Verbose.IsPresent) {
        $expression += ' -v';
    }
    $expression += ' prune';
    if($WhatIf.IsPresent) {
        $expression += ' --dry-run';
    }
    $expression += ' origin';
    return $expression;
}

# `System.IO.Directory.GetDirectories(...[SearchOption]::AllDirectories)` is much faster in PowerShell than `Get-ChildItem -Directory -r`
foreach($item in $([Directory]::GetDirectories($currentDir, '.git', [SearchOption]::AllDirectories);)) {
    $dir = get-item -Force $item;
    Push-Location $dir.Parent;
    try {
        Write-Verbose "pruning in $((Get-Location).Path)...";
        $expression = Build-Command;

        Invoke-expression $expression;
    } finally {
        Pop-Location;
    }
}