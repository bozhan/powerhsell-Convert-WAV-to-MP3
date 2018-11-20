param (
	[String]$d,
	[String[]]$t = ('.wav'),
	[String]$b = 320,
	[switch]$help,
	[switch]$r
)

filter Where-Extension {
param([String[]] $extension = $t)
	$_ | Where-Object {
		$extension -contains $_.Extension
	}
}

function Check-If-Help-Required{
	if($help.ispresent){
		write-host("`n")
		write-host("SYNTAX")
		write-host("  " + "Convert-WAV-to-MP3 [[-d]<string>] [[-t]<string[]=('.wav')>] [[-b]<integer=320>] [[-r]<switch>]")
		write-host("`n")
		write-host("DESCRIPTION")
		write-host("  " + "{0,-15} {1}" -f "-d", "Specify directrory to containing media files.")
		write-host("  " + "{0,-15} {1}" -f "-t", "Specify media file types.")
		write-host("  " + "{0,-15} {1}" -f "-b", "Set sampling bitrate.")
		write-host("  " + "{0,-15} {1}" -f "-r", "Search directory recursively for files.")
		write-host("`n")
		exit
	}
}

function Get-Script-Folder-Path{
  return Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent
}

function Get-Lame-Path{
	$scriptFolder = Get-Script-Folder-Path
	$filesInScriptFolder = @(Get-ChildItem -literalPath $scriptFolder)
	$lame = ""
	if ($filesInScriptFolder.count -gt 0){
		foreach($file in $filesInScriptFolder){
			if ($file.Name.ToLower().CompareTo("lame.exe") -eq 0){
				$lame = $file.FullName
			}
		}
	}
	if (($filesInScriptFolder.count -eq 0) -or ($lame.CompareTo("") -eq 0)){
		Throw [System.IO.FileNotFoundException] "Executable lame.exe missing from folder:""$scriptFolder"""
	}
	return $lame
}

function ConvertToMP3([string]$folderPath, [String[]]$fileTypes, [String]$bitrate, [switch]$recurse){
	$lame = Get-Lame-Path
	
	if($recurse){
		$files = @(Get-ChildItem -literalPath $folderPath -recurse | Where-Extension $fileTypes)
	}else{
		$files = @(Get-ChildItem -literalPath $folderPath | Where-Extension $fileTypes)
	}
		
	if($files.count -gt 0){
		foreach($file in $files){
			$i = $file.FullName
			$newFileName = $file.basename + ".mp3"
			$o = join-path -path $file.Directory $newFileName
			write-host("bitrate: "+$bitrate)
			&$lame -b $bitrate -h $i $o | Out-Null
		}
	}else{
		write-host($files.count + " - found in " + $folderPath)
	}
}

Check-If-Help-Required
while ($d.CompareTo("") -eq 0){
	$d = $(Read-Host 'Source Folder')
}
ConvertToMP3 $d $t $b $r



