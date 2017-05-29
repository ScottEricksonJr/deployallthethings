############################################## 
#                                            # 
# File:     Copymms2017Files.ps1             # 
# Author:   Duncan Russell                   # 
#           http://www.sysadmintechnotes.com # 
# Edited:   Andrew Johnson                   # 
#           http://www.andrewj.net           # 
# Edited:   Scott Erickson                   # 
#           http://deployallthethings.com    # 
############################################## 
 

 $baseLocation = 'C:\Conferences\MMS'
 $username = 'username@domain.com'
 $password = 'password'
  
 Clear-Host 
 $MMSDates='http://mms2017.sched.org/2017-05-14', 'http://mms2017.sched.org/2017-05-15', 'http://mms2017.sched.org/2017-05-16','http://mms2017.sched.org/2017-05-17','http://mms2017.sched.org/2017-05-18' 
 ForEach ($Date in $MMSDates) 
 { 
 $uri = $Date 
 
 $login = Invoke-WebRequest -Uri 'https://mms2017.sched.com/login' -SessionVariable $mms 
 $form = $login.forms | where method -eq post
 $form.fields["username"] = $username
 $form.fields["password"] = $password
 $login = Invoke-WebRequest -uri ("https://mms2017.sched.com/login" + $Form.Action) -WebSession $mms -Method Post -Body $form.fields
 
 $sched = Invoke-WebRequest -Uri $uri -WebSession $mms 
 $links = $sched.Links 
 $links | ForEach-Object { 
     if(($PSItem.href -like '*event/*') -and ($PSItem.innerText -notlike '*birds*')) 
     { 
         $eventUrl = $PSItem.href 
         $eventTitle = $($PSItem.innerText -replace "full$", "") -replace "filling$", ""  
         "Checking session '{0}' for downloads" -f $eventTitle 
         $eventTitle = $eventTitle -replace "\W+", "_" 
          
         $uri = 'http://mms2017.sched.org' 
         $event = Invoke-WebRequest -Uri $($uri + $eventUrl) -WebSession $mms 
         $eventLinks = $event.Links 
 

         $eventLinks | ForEach-Object {  
             $eventFileUrl = $PSItem.href;$filename = $PSItem.href;if($eventFileUrl -like '*hosted_files*') 
             { 
                 $downloadPath = $baseLocation + '\mms2017\' + $eventTitle 
                 $filename = $filename.substring(39) 
                 $filename = $filename.Replace('%20',' ') 
                 $outputFilePath = $downloadPath + '\' + $filename 
                 if((Test-Path -Path $($downloadPath)) -eq $false){New-Item -ItemType Directory -Force -Path $downloadPath | Out-Null} 
                 if((Test-Path -Path $outputFilePath) -eq $false) 
                 { 
                     "...attempting to download '{0}'" -f $filename 
                     Invoke-WebRequest -Uri $eventFileUrl -OutFile $outputfilepath -WebSession $mms;$doDownload=$false; 
                     Unblock-File $outputFilePath 
                     $stopit = $true 
                 } 
             }  
         } 
     } 
 } 
 } 
