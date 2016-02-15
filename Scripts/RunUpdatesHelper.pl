#!/usr/bin/perl -w

use strict;

my $AVAILABLEUPDATES="";

$AVAILABLEUPDATES=`/usr/sbin/softwareupdate --list`;
chomp $AVAILABLEUPDATES;

printf "available updates is %s \n\n", "$AVAILABLEUPDATES";

# If available updates contains * there are updates available

if ($AVAILABLEUPDATES=~/\*/){

        printf "there are updates available\n";

        if ($AVAILABLEUPDATES=~/restart/){

                printf "updates need a restart\n";

                my $LOGGEDINUSER='';

                $LOGGEDINUSER=`/usr/bin/who | /usr/bin/grep console | /usr/bin/cut -d " " -f 1`;
                chomp $LOGGEDINUSER;

                printf "value of logged in user is $LOGGEDINUSER..\n";

                if ($LOGGEDINUSER=~/[a-zA-Z]/) {

                        printf "as there is a logged in user checking whether ok to restart\n";

                        my $RESPONSE = "";

                        $RESPONSE=system '\'/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper\' -startlaunchd -windowType utility -icon \'/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/Resources/Message.png\' -heading "Software Updates are available" -description "Your computer will need to restart, would you like to install the updates now?" -button1 "Yes" -button2 "Cancel" -cancelButton "2"';

                        if ($RESPONSE eq "0") {
                                printf "\nUser said YES to Updates\n";
                                system "/usr/local/jamf/bin/jamf policy -trigger runsoftwareupdate";
                                exit 0;
                        } else {
                                printf "\nUser said NO to Updates\n";
                                exit 0;
                        }
                }
                else {
                        printf "no logged in user so ok to run updates\n";
                        system "/usr/local/jamf/bin/jamf policy -trigger runsoftwareupdate";
                        exit 0;
                }
        }
        else {
                printf "no restart required\n";
                system "/usr/local/jamf/bin/jamf policy -trigger runsoftwareupdate";
                exit 0;
        }
}
else {
        printf "there are no updates available\n";
        exit 0;
}
exit 0;