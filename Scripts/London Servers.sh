sjlip=$(ifconfig | grep 10.1 | awk '{print $2}')
lhip=$(ifconfig | grep 10.9 | awk '{print $2}')
sjlip=${sjlip:0:4}
lhip=${lhip:0:4}

if [[ $sjlip == "10.1" ]] ; then
 akqa=true
elif [[ $lhip == "10.9" ]] ; then
 akqa=true
else
 akqa=false
fi

if [[ $akqa == "true" ]] ; then
 pass=$(osascript -e 'Tell application "System Events" to display dialog "Please enter password  to connect to AKQA resources:" default answer "" with hidden answer' -e 'text returned of        result' 2>/dev/null)
 mkdir /Volumes/Client01 > /var/log/test.log
 mkdir /Volumes/Client02 > /var/log/test.log
 mkdir /Volumes/Documents > /var/log/test.log
 mkdir /Volumes/Departments > /var/log/test.log
 mkdir /Volumes/Transfer > /var/log/test.log
 mkdir /Volumes/ELC > /var/log/test.log
 mount_smbfs "//$3:$pass@lonfiles.emea.akqa.local/Client01" "/Volumes/Client01" > /var/log/test.log
 mount_smbfs "//$3:$pass@lonfiles.emea.akqa.local/Client02" "/Volumes/Client02" > /var/log/test.log
 mount_smbfs "//$3:$pass@lonfiles.emea.akqa.local/Documents" "/Volumes/Documents" > /var/log/test.log
 mount_smbfs "//$3:$pass@lonfiles.emea.akqa.local/Departments" "/Volumes/Departments" > /var/log/test.log
 mount_smbfs "//$3:$pass@lonfiles.emea.akqa.local/Transfer" "/Volumes/Transfer" > /var/log/test.log
 mount_smbfs "//emea;$3:$pass@lonegnyte.emea.akqa.local/ELC" "/Volumes/ELC" > /var/log/test.log
else
 exit 1
fi