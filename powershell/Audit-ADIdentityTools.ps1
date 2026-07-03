#
SYNOPSIS
    Interactive Active Directory Audit and Identity Tool.
DESCRIPTION
    This script provides an interactive CLI menu to quickly audit service accounts,
    find group/resource owners (Sponsors), and check specific user memberships.
NOTES
    Author: MGC
    Requirement: ActiveDirectory PowerShell Module
#

# This ensure the Active Directory module is fully loaded
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Warning "The ActiveDirectory module is required to run this script. Please install RSAT."
    Exit
}

Import-Module ActiveDirectory

function Show-Menu {
    Clear-Host
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "        ACTIVE DIRECTORY IAM & AUDIT TOOLKIT             " -ForegroundColor Cyan
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "1. List all Domain Service Accounts (SPN Filter)"
    Write-Host "2. Find Owner/Sponsor of a Security Group (ManagedBy)"
    Write-Host "3. Check Specific Group Memberships for a User"
    Write-Host "4. Exit"
    Write-Host "=========================================================" -ForegroundColor Cyan
}

do {
    Show-Menu
    $choice = Read-Host "Select an option [1-4]"

    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host "--- Auditing Service Accounts (Accounts with SPNs) ---`n" -ForegroundColor Yellow
            try {
                # Fetches standard user accounts configured as service accounts via SPN
                $svcAccounts = Get-ADUser -Filter 'ServicePrincipalNames -like "*"' -Properties ServicePrincipalNames | 
                               Select-Object Name, SamAccountName, UserPrincipalName
                
                if ($svcAccounts) {
                    $svcAccounts | Format-Table -AutoSize
                } else {
                    Write-Host "No service accounts found with active SPNs." -ForegroundColor Red
                }
            } catch {
                Write-Error "Failed to retrieve service accounts. Error: $_"
            }
            Read-Host "`nPress Enter to return to the menu"
        }

        "2" {
            Clear-Host
            Write-Host "--- Find Security Group Owner / Sponsor ---`n" -ForegroundColor Yellow
            $groupName = Read-Host "Enter the target Security Group Name"
            
            try {
                $group = Get-ADGroup -Identity $groupName -Properties ManagedBy
                if ($group.ManagedBy) {
                    # Resolves the ManagedBy attribute distinguished name to get a  clean name
                    $owner = Get-ADObject -Identity $group.ManagedBy
                    Write-Host "The official Owner/Sponsor for group " -NoNewline
                    Write-Host "[$groupName]" -ForegroundColor Green -NoNewline
                    Write-Host " is: " -NoNewline
                    Write-Host $owner.Name -ForegroundColor Cyan
                } else {
                    Write-Host "The group [$groupName] exists, but has no Owner (ManagedBy) assigned." -ForegroundColor Red
                }
            } catch {
                Write-Host "Group [$groupName] could not be found. Please check the spelling." -ForegroundColor Red
            }
            Read-Host "`nPress Enter to return to the menu"
        }

        "3" {
            Clear-Host
            Write-Host "--- Audit User Group Membership ---`n" -ForegroundColor Yellow
            $username = Read-Host "Enter the SamAccountName (username) to audit"
            
            try {
                $user = Get-ADUser -Identity $username
                Write-Host "Explicit memberships found for user: " -NoNewline
                Write-Host $user.Name -ForegroundColor Green -BackgroundColor Black
                Write-Host ""
                
                Get-ADPrincipalGroupMembership -Identity $username | 
                    Select-Object Name, GroupScope, GroupCategory | 
                    Format-Table -AutoSize
            } catch {
                Write-Host "User [$username] not found in Active Directory." -ForegroundColor Red
            }
            Read-Host "`nPress Enter to return to the menu"
        }

        "4" {
            Write-Host "`nThank you for using the AD Audit Toolkit. Exiting..." -ForegroundColor Green
            Start-Sleep -Seconds 1
            Clear-Host
        }

        Default {
            Write-Host "Invalid choice. Please choose an option between 1 and 4." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($choice -ne "4")
