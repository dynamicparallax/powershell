# Text Display
"DO NOT CLOSE THIS WINDOW, IT WILL CLOSE AFTER IT IS COMPLETED."

function Get-ScreenShot
{
    [CmdletBinding()]
    param(
        [parameter(Position  = 0, Mandatory = 0, ValueFromPipelinebyPropertyName = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$OutPath = "C:\Powershell_out",
 
        #screenshot_[yyyyMMdd_HHmmss_ffff].png
        [parameter(Position  = 1, Mandatory = 0, ValueFromPipelinebyPropertyName = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$FileNamePattern = 'screenshot_{0}.png',
 
        [parameter(Position  = 2,Mandatory = 0, ValueFromPipeline = 1, ValueFromPipelinebyPropertyName = 1)]
        [ValidateNotNullOrEmpty()]
        [int]$RepeatTimes = 0,
 
        [parameter(Position  = 3, Mandatory = 0, ValueFromPipelinebyPropertyName = 1)]
        [ValidateNotNullOrEmpty()]
        [int]$DurationMs = 1
     )
 
     begin
     {
        $ErrorActionPreference = 'Stop'
        Add-Type -AssemblyName System.Windows.Forms
 
        if (-not (Test-Path $OutPath))
        {
            New-Item $OutPath -ItemType Directory -Force
        }
     }
 
     process
     {
        0..$RepeatTimes `
        | %{
            $fileName = $FileNamePattern -f (Get-Date).ToString('yyyyMMdd_HHmmss_ffff')
            $path = Join-Path $OutPath $fileName
 
            $b = New-Object System.Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height)
            $g = [System.Drawing.Graphics]::FromImage($b)
            $g.CopyFromScreen((New-Object System.Drawing.Point(0,0)), (New-Object System.Drawing.Point(0,0)), $b.Size)
            $g.Dispose()
            $b.Save($path)
 
            if ($RepeatTimes -ne 0)
            {
                Start-Sleep -Milliseconds $DurationMs
            }
        }
    }
}

# Create folder name in server01
New-Item \\server01\Results\$env:computername -type directory -force

# Take a screentshot
Get-Screenshot "\\server01\Results\$env:computername\screenshot_$(get-date -f yyy-MM-dd-hh-mm)_$env:computername"

# Get software installed with versions, output to server01
Get-WmiObject -Class Win32_Product -Computer . | select-object Name, Vendor, Version | Export-CSV  "\\server01\Results\$env:computername\Software_$(get-date -f yyy-MM-dd-hh-mm)_$env:computername.csv" -notypeinformation

# Get services status , output to server01
Get-WmiObject -Class Win32_Service -Computer . | select-object Name, State | Export-CSV  "\\server01\Results\$env:computername\Services_$(get-date -f yyy-MM-dd-hh-mm)_$env:computername.csv" 

# Get processes with path, output to server01
Get-WmiObject -Class Win32_Process -Computer . | select-object Name, Path | Export-CSV  "\\server01\Results\$env:computername\Process_$(get-date -f yyy-MM-dd-hh-mm)_$env:computername.csv" 
