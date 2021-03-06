function collect_winfo () {
	#does everything
	get_win32_computersystem | export-csv -NoTypeInformation computer.csv
  	get_win32_operatingsystem | export-csv -NoTypeInformation os.csv
	get_win32_logicaldisk | export-csv -NoTypeInformation disks.csv
	get_win32_physicalmemory | export-csv -NoTypeInformation memory.csv
	get_win32_process | export-csv -NoTypeInformation processes.csv
	get_win32_service | export-csv -NoTypeInformation services.csv
	get_win32_product | export-csv -NoTypeInformation installed_software.csv
	get_win32_quickfixengineering | export-csv -NoTypeInformation installed_hotfixes.csv
	get_iis_metabase 
}

function get_win32_computersystem(){
	return get-wmiobject win32_computersystem | 
	sort Name | 
	select-object Name, Model, Manufacturer, Description, DNSHostName, Domain, DomainRole, PartOfDomain, NumberOfProcessors, SystemType, TotalPhysicalMemory, UserName, Workgroup 
}

function get_win32_operatingsystem(){
   	return get-wmiobject win32_operatingsystem | 
	sort Name | 
	select-object Name, Version, FreePhysicalMemory, OSLanguage, OSProductSuite, OSType, ServicePackMajorVersion, ServicePackMinorVersion
}

function get_win32_logicaldisk(){
   	return get-wmiobject win32_logicaldisk | 
	sort Name | 
	select-object Name, Description, Size, FreeSpace, FileSystem, VolumeName, VolumeSerialNumber, QuotaDisabled
}

function get_win32_physicalmemory(){
   	return get-wmiobject win32_physicalmemory | 
	sort Name | 
	select-object Name, Capacity, DeviceLocator, Tag
}

function get_win32_process(){
   	return get-wmiobject win32_process | 
	sort Name | 
	select-object Name, ProcessID, Handel, VM, WS, UserModeTime, KernelModeTime, PageFaults, PageFileUsage, CommandLine, ExecutablePath
}

function get_win32_service(){
   	return get-wmiobject win32_service | 
	sort Name | 
	select-object Name, Started, StartMode, State, PathName, ProcessID, Status, ExitCode, AcceptStop, AcceptPause, Description
}

function get_win32_product(){
   	return get-wmiobject win32_product | 
	sort Name | 
	select-object Name, Version, Vendor, InstallLocation, InstallDate, PackageCache, Description
}

function get_win32_quickfixengineering(){
   	return get-wmiobject win32_quickfixengineering | 
	sort Name | 
	select-object HotfixID, Description, InstalledOn, InstalledBy
}

function get_iis_metabase(){
	#need to make this relative to the $env
	$backup_path = "c:\windows\System32\inetsrv\backup\IISBackup"
	if((is_win_2008) -or (is_win_7)){
		$iisfiles = dir $backup_path\*.xml
		if(-not (Test-Path -Path $backup_path)){
			Import-Module WebAdministration
			Backup-WebConfiguration -Name IISBackup
		}
		if(Test-Path -Path .\IISBackup){
			Remove-Item .\IISBackup -Recurse
		}
		copy-item $backup_path .\IISBackup -recurse
		
	}

}


function is_win_2008(){
    $server08 = $false
    if(Get-WMIObject -List| Where{$_.name -match "^Win32_ServerFeature"}){
      $server08 = $true
    }
    
    $iis6_compat = $false
    if($server08) {
      if (Get-WmiObject Win32_ServerFeature -Filter 'id=180'){
        $iis6_compat = $true
      }
    }
	return $server08 #+ $iis6_compat
}

function is_win_7(){
	$win7 = get-wmiobject win32_operatingsystem -filter "name like '%Windows 7%'" | select name
	return $win7 -ne $null 
}

function send_winfo(){
	#Choose how / choose where
	# cmd -sendto email or -sendto zip or -sendto gist 
}