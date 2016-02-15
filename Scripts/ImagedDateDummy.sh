######################################################################################
# Dummy package with image date
######################################################################################
/bin/echo "Creating imaging receipt..."
/bin/date
TODAY=`date +"%Y-%m-%d"`
touch /Library/Application\ Support/JAMF/Receipts/Imaged_$TODAY.pkg
