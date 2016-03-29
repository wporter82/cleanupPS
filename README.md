# cleanupPS
Cleans a directory of files older than a period of days.

##Options:
###filePath
    Location that the cleanup will be done.
    Default: E:\
###limit
    The total size in GB that the target file path should be before cleaning is done.
    Default: 40
###days
    How many days back files should be kept. Any file older will be deleted.
    Default: 365
###logFile
    Location of the generated log file.
    Default: User's $HOME directory
###WhatIf
    Run without deleting any files, just show what would be deleted.



##Example:
    .\cleanup.ps1 -filePath E:\ -limit 40 -days 365 -logFile cleanup.log

##Usage:
Download and save the file cleanup.ps1 to a safe location. 
Recommendation: 
<code>C:\Users\[username]</code>

Create a new scheduled task by following the steps here:
<a href="http://windows.microsoft.com/en-US/windows/schedule-task">Schedule a task</a>

When you are at the step to choose a program to run, use the following:
<code>powershell -file "[path to cleanup.ps1]" [options]</code>


###Note:
The default values are hard coded to fit my test system but can be modified if necessary in the script.
