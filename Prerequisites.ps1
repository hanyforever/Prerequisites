# Write the current date and time to the screen
Write-Output (Get-Date)

# Operating System Check
Write-Output "Operating System Check..."
# Get the caption, version, and build number of the operating system and display them in a table
Get-CimInstance -Class Win32_OperatingSystem | Format-Table -Property Caption, Version, BuildNumber -AutoSize
# Create new variables for each of these properties and assign them the values
New-Variable -Name Caption -Value (Get-CimInstance -Class Win32_OperatingSystem).Caption
New-Variable -Name Version -Value (Get-CimInstance -Class Win32_OperatingSystem).Version
New-Variable -Name BuildNumber -Value (Get-CimInstance -Class Win32_OperatingSystem).BuildNumber
# Compare the version variable with the minimum required version (10.0.17763) for Windows Server 2019
If ($Version -ge "10.0.17763") {
    # If the version is greater than or equal to the minimum required version, write "Check Passed" in green
    Write-Host "OS Check Passed" -ForegroundColor Green
} Else {
    # If the version is less than the minimum required version, write "Check Failed: OS is lower than Windows Server 2019" in red
    Write-Host "OS Check Failed: OS is lower than Windows Server 2019" -ForegroundColor Red
}

# Memory Check
Write-Output "Memory Check..."
# Get the capacity, speed, memory type, and manufacturer of the physical memory modules and display them in a table
Get-CimInstance -Class Win32_PhysicalMemory | Format-Table -Property Capacity, Speed, MemoryType, Manufacturer -AutoSize
# Create new variables for each of these properties and assign them the values
New-Variable -Name Capacity -Value (Get-CimInstance -Class Win32_PhysicalMemory).Capacity
New-Variable -Name Speed -Value (Measure-Object -InputObject (Get-CimInstance -Class Win32_PhysicalMemory | Select-Object -ExpandProperty Speed) -Average).Average
New-Variable -Name MemoryType -Value (Get-CimInstance -Class Win32_PhysicalMemory | Select-Object -Unique -Property MemoryType).MemoryType
New-Variable -Name Manufacturer -Value (Get-CimInstance -Class Win32_PhysicalMemory | Select-Object -Unique -Property Manufacturer).Manufacturer

# Compare the capacity variable with the minimum required capacity (15179869184) for 14 GB
If ((Measure-Object -InputObject $Capacity -Sum).Sum -ge 15179869184) {
    # If the capacity is greater than or equal to the minimum required capacity, write "Check Passed" in green
    Write-Host "Memory Check Passed" -ForegroundColor Green
} Else {
    # If the capacity is less than the minimum required capacity, write "Check Failed: RAM is lower than 16 GB" in red
    Write-Host "Memory Check Failed: RAM is lower than 14 GB" -ForegroundColor Red
}

# Disk Check
Write-Output "Disk Check..."
# Get the disk number, partition number, drive letter, and free space of the disks and partitions and display them in a table
Get-Disk | Get-Partition | Format-Table -Property DiskNumber, PartitionNumber, DriveLetter, @{Label='FreeSpace (GB)'; Expression={($_.Size - $_.UsedSize)/1GB}} -AutoSize
# Create new variables for each of these properties and assign them the values
New-Variable -Name DiskNumber -Value (Get-Disk | Get-Partition).DiskNumber
New-Variable -Name PartitionNumber -Value (Get-Disk | Get-Partition).PartitionNumber
New-Variable -Name DriveLetter -Value (Get-Disk | Get-Partition).DriveLetter
New-Variable -Name FreeSpace -Value (Get-Disk | Get-Partition).FreeSpace
# Compare the free space variable with the minimum required free space (53687091200) for 50 GB
If ($FreeSpace -ge 53687091200) {
    # If the free space is greater than or equal to the minimum required free space, write "Check Passed" in green
    Write-Host "Disk Check Passed" -ForegroundColor Green
} Else {
    # If the free space is less than the minimum required free space, write "Check Failed: Free disk space is lower than 50 GB" in red
    Write-Host "Disk Check Failed: Free disk space is lower than 50 GB" -ForegroundColor Red
}

# IIS Check
Write-Output "IIS Check..."
# Check the state of the IIS-WebServerRole feature
Get-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
# If the state is Enabled, then IIS is installed on the PC
If ((Get-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole).State -eq "Enabled") {
    # Write "IIS Check Passed" in green
    Write-Host "IIS Check Passed: IIS is Installed" -ForegroundColor Green
} Else {
    # If the state is Disabled, then IIS is not installed but can be enabled
    If ((Get-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole).State -eq "Disabled") {
        # Write "IIS Check Failed: IIS is not installed" in red
        Write-Host "IIS Check Failed: IIS is not installed" -ForegroundColor Red
        # Prompt the user to install IIS with the most common features
        $answer = Read-Host "Do you want to install IIS with the most common features? (Y/N)"
        # If the user answers yes, then install IIS with the most common features
        If ($answer -eq "Y") {
            # Write "Installing IIS..." in yellow
            Write-Host "Installing IIS..." -ForegroundColor Yellow
            # Install IIS with the most common features
            Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -All
            # Write "IIS installed successfully" in green
            Write-Host "IIS installed successfully" -ForegroundColor Green
        # If the user answers no, then do nothing
        } ElseIf ($answer -eq "N") {
            # Write "IIS installation cancelled" in red
            Write-Host "IIS installation cancelled" -ForegroundColor Red
        # If the user answers anything else, then write "Invalid input" in red
        } Else {
            # Write "Invalid input" in red
            Write-Host "Invalid input" -ForegroundColor Red
        }
    # If the state is anything else, then IIS is not installed and cannot be enabled
    } Else {
        # Write "IIS Check Failed: IIS is not available" in red
        Write-Host "IIS Check Failed: IIS is not available" -ForegroundColor Red
    }
}



# Remove the variables that were created in the previous script, so its not conflicting with a second run
Remove-Variable -Name Caption, Version, BuildNumber, Capacity, Speed, MemoryType, Manufacturer, DiskNumber, PartitionNumber, DriveLetter, FreeSpace
