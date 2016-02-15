ls / | grep .pkg | while read thePackage; do
	logger -t packageInstall "Running package $thePackage"
	installer -pkg "/$thePackage" -target /
	rm -fr "/$thePackage"
	logger -t packageInstall "Deleted package $thePackage"
done
jamf manage