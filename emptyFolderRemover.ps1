try { 
    Set-Location $pwd.Path;
    Set-Location -LiteralPath '%V';
    function IsFolderEmpty {
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
    $index = 1;
    foreach ($dir in $directories) {
        if (IsFolderEmpty $dir.FullName) {
            Write-Host ($index.ToString() + '/' + $directories.Count.ToString() + ' - Removing: ' + $dir.FullName);
            try {
                Remove-Item -LiteralPath $dir.FullName -Force -Recurse -Confirm:$false -ErrorAction Stop;
            }
            catch {
                Write-Host ('  Failed to remove ' + $dir.FullName + ': ' + $_.Exception.Message) -ForegroundColor Red;
            }
        }
        $index++;
    }
    $rootPath = (Get-Location).Path;
    if (IsFolderEmpty $rootPath) {
        Write-Host ('Removing scanned folder itself: ' + $rootPath);
        try {
            Set-Location -LiteralPath (Split-Path $rootPath -Parent) -ErrorAction Stop;
            Remove-Item -LiteralPath $rootPath -Force -Recurse -Confirm:$false -ErrorAction Stop;
        }
        catch {
            Write-Host ('  Failed to remove ' + $rootPath + ': ' + $_.Exception.Message) -ForegroundColor Red;
        }
    }
}
catch {
    Write-Host ('An error occured while removing empty folders recursively: ' + $_.Exception.Message) -ForegroundColor Red;
}
Write-Host 'Press any key to exit...';
$Host.UI.RawUI.ReadKey('NoEcho, IncludeKeyDown') | OUT-NULL;
$Host.UI.RawUI.FlushInputbuffer();
exit;
