#!/bin/bash



user=`who |grep console| awk '{print $1}'`

fullname=`dscl . -read /Users/$user RealName | awk -F 'RealName:' '{ print $1 }'`

email=`dscl . -read /Users/$user EMailAddress | awk '{ print $2 }' | awk '{print tolower($0)}'`

phonenumber=`dscl . -read /Users/$user PhoneNumber | awk -F 'PhoneNumber:' '{ print $1 }'`

jobtitle=`dscl . -read /Users/$user JobTitle | awk -F 'JobTitle:' '{ print $1 }'`

direct=""

if [[ -z $phonenumber ]] ; then
direct=""
else
direct="Direct $phonenumber<br>"
fi

osascript <<EOD

tell application "Microsoft Outlook"
	make new signature with properties {name:"AKQA London SJL", content:"<font face=\"Verdana\"><font size=\"2\"><b><br>--</br><br>$fullname</b><br>
	$jobtitle<br>
	<br>
	$direct
	<br>
	<a href=\"mailto:$email\">$email</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;<a href=\"http://www.akqa.com\">http://www.akqa.com</a><br>
	<br>
	AKQA, 1 St John's Lane, London EC1M 4BL, UK<br>
	<font color=#808080>Registered in England: 2964394<br>
	<br>
	Confidentiality notice: <br>
The information transmitted in this email and/or any attached document(s) is confidential and intended only for the person or entity to which it is addressed and may contain privileged material. Any review, retransmission, dissemination or other use of, or taking of any action in reliance upon this information by persons or entities other than the intended recipient is prohibited. If you received this in error, please contact the sender and delete the material from any computer.<br></font>
	</font></size>"}
end tell

EOD