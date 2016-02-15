#!/bin/sh
####################################################################################################
#
# Copyright (c) 2010, JAMF Software, LLC.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the JAMF Software, LLC nor the
#                 names of its contributors may be used to endorse or promote products
#                 derived from this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
####################################################################################################
#
# SUPPORT FOR THIS PROGRAM
#
#       This program is distributed "as is" by JAMF Software, LLC's Resource Kit team. For more
#       information or support for the Resource Kit, please utilize the following resources:
#
#               http://list.jamfsoftware.com/mailman/listinfo/resourcekit
#
#               http://www.jamfsoftware.com/support/resource-kit
#
#       Please reference our SLA for information regarding support of this application:
#
#               http://www.jamfsoftware.com/support/resource-kit-sla
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	flushPolicyHistory.sh -- Flush an individual computer's policy history in the JSS.
#
# SYNOPSIS
#	sudo flushPolicyHistory.sh
#	sudo flushPolicyHistory.sh <mountPoint> <computerName> <currentUsername>
#
# DESCRIPTION
#	This script is designed to be run on any clients that have been previously managed by
#	The Casper Suite.  Running the script will attempt to connect to the JAMF Software Server
#	(JSS) and will flush any historical policy logs for the computer so that the computer appears
#	to have not run any policies.
#
#	This script is most commonly used as an "At Reboot" script that runs as part of a Casper Imaging
#	configuration to ensure that any policies that were previously run on a client will run again
#	after the machine has been re-imaged.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen on August 6th, 2008
#
####################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################
#
# Flush Policy History for Computer in JAMF Software Server Upon Reimage
/usr/local/jamf/bin/jamf flushPolicyHistory