#!/bin/bash

# Remove all St Johns' Printers
lpadmin -x LON_FLOOR4_PURPLE
lpadmin -x LON_FLOOR4_BLUE
lpadmin -x LON_FLOOR4_RED
lpadmin -x LON_FLOOR4_GOLD
lpadmin -x LON_FLOOR3_PLUM
lpadmin -x LON_FLOOR3_ORANGE
lpadmin -x LON_FLOOR4_MAROON_COLOUR
lpadmin -x LON_FLOOR4_WHITE_COLOUR
lpadmin -x LON_FLOOR3_CHARCOAL_COLOUR
lpadmin -x LON_FLOOR2_BRASS_COLOUR
lpadmin -x LON_FLOOR2_COPPER_COLOUR

# St John
lpadmin -p LON_FLOOR4_PURPLE -E -v lpd://10.1.100.152 -P "/Library/Printers/PPDs/Contents/Resources/HP LaserJet 5200.gz"
lpadmin -p LON_FLOOR4_BLUE -E -v lpd://10.1.100.101 -P "/Library/Printers/PPDs/Contents/Resources/CNADVC5250X1.PPD.gz"
lpadmin -p LON_FLOOR4_RED -E -v lpd://10.1.100.54 -P "/Library/Printers/PPDs/Contents/Resources/HP LaserJet 5200.gz"
#### lpadmin -p LON_FLOOR4_GOLD -E -v lpd://10.2.100.45 -P "/Library/Printers/PPDs/Contents/Resources/HP LaserJet 5200.gz"
lpadmin -p LON_FLOOR3_PLUM -E -v lpd://10.1.120.9 -P "/Library/Printers/PPDs/Contents/Resources/HP LaserJet 5200.gz"
lpadmin -p LON_FLOOR3_BLACK -E -v lpd://10.1.120.14 -P "/Library/Printers/PPDs/Contents/Resources/CNADVC5250X1.PPD.gz"
#### lpadmin -p LON_FLOOR3_CHARCOAL_COLOUR -E -v lpd://10.1.121.59 -P "/Library/Printers/PPDs/Contents/Resources/CNADVC7055X1.PPD.gz"
lpadmin -p LON_FLOOR3_CHARCOAL_COLOUR -E -v lpd://10.1.120.90 -P "/Library/Printers/PPDs/Contents/Resources/CNPZUIRAC7260ZU.ppd.gz"
lpadmin -p LON_FLOOR4_MAROON_COLOUR -E -v lpd://10.1.100.3 -P "/Library/Printers/PPDs/Contents/Resources/CNADVC5250X1.PPD.gz"
lpadmin -p LON_FLOOR4_WHITE_COLOUR -E -v lpd://10.1.100.17 -P "/Library/Printers/PPDs/Contents/Resources/CNADVC5250X1.PPD.gz"
lpadmin -p LON_FLOOR2_BRASS_COLOUR -E -v lpd://10.1.150.5 -P "/Library/Printers/PPDs/Contents/Resources/CNADVC5250X1.PPD.gz"
lpadmin -p LON_FLOOR2_COPPER_COLOUR -E -v lpd://10.1.150.6 -P "/Library/Printers/PPDs/Contents/Resources/CNADVC7055X1.PPD.gz"

# Layden House
lpadmin -p LDH_FLOOR5_MINKE_BW -E -v lpd://10.9.100.200 -P "/Library/Printers/PPDs/Contents/Resources/HP LaserJet 5200.gz"
lpadmin -p LDH_FLOOR5_ORCA_BW -E -v lpd://10.9.100.202 -P "/Library/Printers/PPDs/Contents/Resources/HP LaserJet 5200.gz"
lpadmin -p LDH_FLOOR4_CORAL_BW -E -v lpd://10.9.100.203 -P "/Library/Printers/PPDs/Contents/Resources/HP LaserJet 5200.gz"
lpadmin -p LDH_FLOOR4_CAPPI_BW -E -v lpd://10.9.100.204 -P "/Library/Printers/PPDs/Contents/Resources/HP LaserJet 5200.gz"
lpadmin -p LDH_FLOOR5_BELUGA_COLOUR -E -v lpd://10.9.100.207 -P "/Library/Printers/PPDs/Contents/Resources/CNADVC5250X1.PPD.gz"
lpadmin -p LDH_FLOOR4_COLOUR -E -v lpd://10.9.100.205 -P "/Library/Printers/PPDs/Contents/Resources/CNADVC5250X1.PPD.gz"