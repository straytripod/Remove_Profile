<#   
.SYNOPSIS   
    Interactive menu that allows a user to connect to a local or remote computer and remove a local profile. 
.DESCRIPTION 
    Presents an interactive menu for user to first make a connection to a remote or local machine.  After making connection to the machine,  
    the user is presented with all of the local profiles and then is asked to make a selection of which profile to delete. This is only valid 
    on Windows Vista OS and above for clients and Windows 2008 and above for server OS.    
.NOTES   
    Name: Remove-LocalProfile 
    Author: Boe Prox 
    Modifier: StrayTripod
    DateCreated: 26JAN2011
    DateModifed: 8/23/2019
          
.LINK   
    https://boeprox.wordpress.com
    http://msdn.microsoft.com/en-us/library/ee886409%28v=vs.85%29.aspx 
.EXAMPLE  
Remove-LocalProfile 
  
Description 
----------- 
Presents a text based menu for the user to interactively remove a local profile on local or remote machine.    
#> 
  
#Prompt for a computer to connect to 
$computer = Read-Host "Please enter a computer name"
#Test network connection before making connection 
If ($computer -ne $Env:Computername) { 
    If (!(Test-Connection -comp $computer -count 1 -quiet)) { 
        Write-Warning "$computer is not accessible, please try a different computer or verify it is powered on."
        Break
        } 
    } 
Try {     
    #Verify that the OS Version is 6.0 and above, otherwise the script will fail 
    If ((Get-WmiObject -ComputerName $computer Win32_OperatingSystem -ea stop).Version -lt 6.0.0) { 
        Write-Warning "The Operating System of the computer is not supported.`nClient: Vista and above`nServer: Windows 2008 and above."
        Break
        } 
    } 
Catch { 
    Write-Warning "$($error[0])"
    Break
    }     
Do {     
#Gather all of the user profiles on computer 
Try { 
    [array]$users = Get-WmiObject -ComputerName $computer Win32_UserProfile -filter "LocalPath Like 'C:\\Users\\%'" -ea stop 
    } 
Catch { 
    Write-Warning "$($error[0]) "
    Break
    }     
#Cache the number of users 
$num_users = $users.count 
  
Write-Host -ForegroundColor Green "User profiles on $($computer):"
  
    #Begin iterating through all of the accounts to display 
    For ($i=0;$i -lt $num_users; $i++) { 
        Write-Host -ForegroundColor Green "$($i): $(($users[$i].localpath).replace('C:\Users\',''))"
        } 
    Write-Host -ForegroundColor Green "q: Quit"
    #Prompt for user to select a profile to remove from computer 
    Do {     
        $account = Read-Host "Select a number to delete local profile or 'q' to quit"
        #Find out if user selected to quit, otherwise answer is an integer 
        If ($account -NotLike "q*") { 
            $account = $account -as [int]
            } 
        }         
    #Ensure that the selection is a number and within the valid range 
    Until (($account -lt $num_users -AND $account -match "\d") -OR $account -Like "q*") 
    If ($account -Like "q*") { 
        Break
        } 
    Write-Host -ForegroundColor Yellow "Deleting profile: $(($users[$account].localpath).replace('C:\Users\',''))"
    #Remove the local profile 
    ($users[$account]).Delete() 
    Write-Host -ForegroundColor Green "Profile:  $(($users[$account].localpath).replace('C:\Users\','')) has been deleted"
  
    #Configure yes choice 
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Remove another profile."
  
    #Configure no choice 
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No","Quit profile removal"
  
    #Determine Values for Choice 
    $choice = [System.Management.Automation.Host.ChoiceDescription[]] @($yes,$no) 
  
    #Determine Default Selection 
    [int]$default = 0 
  
    #Present choice option to user 
    $userchoice = $host.ui.PromptforChoice("","Remove Another Profile?",$choice,$default) 
    } 
#If user selects No, then quit the script     
Until ($userchoice -eq 1)
