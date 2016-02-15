#!/bin/bash

computerName="$(scutil --get ComputerName)"
diskutil rename disk0s2 $computerName

exit 0