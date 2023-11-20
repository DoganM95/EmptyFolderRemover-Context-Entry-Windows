try {
    $pathToWrite = $pwd.Path.Replace('Microsoft.PowerShell.Core\FileSystem::', '');
    Set-Location $pathToWrite;
    function IsFolderEmptyOrDesktopIniOnly {
        param (
            [string]$folderPath
        );
        $allItems = Get-ChildItem -Path $folderPath -Force;
        $fileItems = $allItems | Where-Object { -not $_.PSIsContainer };
        $directoryItems = $allItems | Where-Object { $_.PSIsContainer };
        if ($fileItems.Count -eq 0 -and $directoryItems.Count -eq 0) {
            return $true;
        }
        elseif ($fileItems.Count -eq 1 -and $fileItems[0].Name -eq 'desktop.ini' -and $directoryItems.Count -eq 0) {
            return $true;
        }
        else {
            return $false;
        }
    }
    $directories = Get-ChildItem -Path . -Recurse -Directory -Force | Sort-Object { $_.FullName.Split('\').Count } -Descending;
    foreach ($dir in $directories) {
        if (IsFolderEmptyOrDesktopIniOnly $dir.FullName) {
            Write-Host 'Removing: $($dir.FullName)';
            Remove-Item $dir.FullName -Force -Recurse -Confirm:$false;
        }
    }
}
catch {
    Write-Host 'An error occured while removing empty folders recursively.' -ForegroundColor Red;
}

Write-Host 'Press any key to exit...';
$Host.UI.RawUI.ReadKey('NoEcho, IncludeKeyDown') | OUT-NULL;
$Host.UI.RawUI.FlushInputbuffer();
exit;