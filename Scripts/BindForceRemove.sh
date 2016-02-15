#!/bin/bash

# OS X doesn't care if the AD account doesn't exist, it'll still remove the bind from the Mac
dsconfigad -force -remove -u johndoe -p nopasswordhere