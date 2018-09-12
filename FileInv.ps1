Set-StrictMode -version 3
$inventoryPath = "C:\Script\user\" # inventory text files created in this path
$items = Get-ChildItem -Path "\\server01\Public\"  # path script runs against

$FileDir =  "\\server01\Public\"  # path script runs against

$ErrorActionPreference = 'Inquire' 
$WarningPreference = 'Inquire'

function LoopSubFoldersAndFiles($RootPath){
foreach ($item in $items)
    {
        if ($item.Attributes -eq "Directory")
            {
                $OutFileName = $item.Name.Replace(" ","-")

                $OutDirectoryName = $inventoryPath + $item.Name + "\"

                New-Item $OutDirectoryName -ItemType Directory
    
                $OutFilePermissions = $OutDirectoryName +$OutFileName +"_Permissions.csv"
                $OutFolderInfo = $OutDirectoryName +$OutFileName +"_Folders.csv"
                $OutFileInfo = $OutDirectoryName +$OutFileName +"_Files.csv"

                Del $OutFilePermissions -ErrorAction SilentlyContinue
                Del $OutFolderInfo -ErrorAction SilentlyContinue
                Del $OutFileInfo -ErrorAction SilentlyContinue
    
                Add-Content -Value  "Folder Path|IdentityReference|AccessControlType" -Path $OutFilePermissions 
                Add-Content -Value  "Folder Path|LastWriteTime|Size|FileCount|Levels|CleanFolderName|Choice" -Path $OutFolderInfo 
                Add-Content -Value  "Folder Path|FileName|LastWriteTime|Size|Extension" -Path $OutFileInfo     
                
                Write-Host $FileDir$item
                $Folders = Get-ChildItem -Path $FileDir$item
    
                foreach ($Folder in $Folders){
                    if($Folder.Attributes -eq "Directory")
                    {
                        if($Folder -ne $null){
                            $ACLs = get-acl $Folder.Fullname | ForEach-Object { $_.Access  }
                            $CleanFolderName = $Folder.Fullname.Replace(",","") #Remove commas in folder names
                                 Foreach ($ACL in $ACLs){
                                    if($ACL -ne $null){
                                        if($ACL.IdentityReference -ne "BUILTIN\Administratörer" -and $ACL.IdentityReference -ne "NT instans\SYSTEM"){
                                            $OutInfo = $CleanFolderName + "|" + $ACL.IdentityReference  + "|" + $ACL.AccessControlType 
                                            Add-Content -Value $OutInfo -Path $OutFilePermissions
                                        }
                                    }
                                }
                                $FSOFolder = $fso.GetFolder($Folder.Fullname)
                                $FolderSize = "{0:N2}" -f ($FSOFolder.size / 1MB) 
                                $FolderFileCount = $FSOFolder.Files.Count 
                                $OutInfo = $CleanFolderName + "|"  + $Folder.LastWriteTime  + "|" + $FolderSize +"|" + $FolderFileCount + "|" + $CleanFolderName.split("\").Length+ "|" + $CleanFolderName.split("\")[$CleanFolderName.split("\").Length-1]
                                Add-Content -Value $OutInfo -Path $OutFolderInfo
                                if($FolderFileCount -gt 0){
                                    $Files = dir $Folder.Fullname | where {$_.psiscontainer -eq $false}
                                    if($Files -ne $null){
                                        Foreach ($File in $Files){
                                            $FileSize = "{0:N2}" -f ($File.Length / 1MB) 
                                            $OutInfo = $CleanFolderName + "|" + $File.Name  + "|" + $File.LastWriteTime + "|" + $FileSize + "|" + $File.Extension
                                            Add-Content -Value $OutInfo -Path $OutFileInfo
                                        }
                                    }
                                }
                            Write-Host $CleanFolderName   
                        }
                    }
            }
        }
    }
}



$fso = New-Object -comobject Scripting.FileSystemObject

LoopSubFoldersAndFiles($FileDir)


write-host "Done!"