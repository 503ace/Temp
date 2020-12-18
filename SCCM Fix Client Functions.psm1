$ClientACtion = @(
    "{00000000-0000-0000-0000-000000000121}",
    "{00000000-0000-0000-0000-000000000003}",
    "{00000000-0000-0000-0000-000000000104}",
    "{00000000-0000-0000-0000-000000000001}",
    "{00000000-0000-0000-0000-000000000021}",
    "{00000000-0000-0000-0000-000000000002}",
    "{00000000-0000-0000-0000-000000000031}",
    "{00000000-0000-0000-0000-000000000108}",
    "{00000000-0000-0000-0000-000000000113}",
    "{00000000-0000-0000-0000-000000000026}",
    "{00000000-0000-0000-0000-000000000032}"
)

function RunCCMActions()
{
    [parameter(Position=0, Mandatory=$true, HelpMessage="Provide Remote Hostname")][string]$Hostname

    if(Test-Connection -ComputerName $Hostname -count 1)
    {
        invoke-command -ComputerName $Hostname -ScriptBlock{
            foreach($Action in $ClientACtion)
            {
                try 
                {
                    [void]([wmiclass] "root\ccm:SMS_Client").TriggerSchedule($ScheduleID);
                }
                catch 
                {
                    #Error during client actions
                    return -2
                }
            }
        }
    }
    else 
    {
        #Host not rechable
        return -1
    }
    return 1
}

function CleanCCMCache()
{
    [parameter(position=0, Mandatory=$true, HelpMessage="Provide Remote Hostname")][string]$Hostname

    if(Test-Connection -ComputerName $Hostname -Count 1)
    {
        Invoke-Command -ComputerName $Hostname -ScriptBlock{
            try {
                ## Initialize the CCM resource manager com object
                [__comobject]$CCMComObject = New-Object -ComObject 'UIResource.UIResourceMgr'
                ## Get the CacheElementIDs to delete
                $CacheInfo = $CCMComObject.GetCacheInfo().GetCacheElements()
                ## Remove cache items
                ForEach ($CacheItem in $CacheInfo) 
                {
                    $null = $CCMComObject.GetCacheInfo().DeleteCacheElement([string]$($CacheItem.CacheElementID))   
                }                 
            }
            catch {
                #Failed CCM Cache Cleanup
                return -2
            }
        }
    }
    else
    {
        #Computer Unreachable
        return -1
    }
}

Export-ModuleMember -Function CleanCCMCache
Export-ModuleMember -Function RunCCMActions