# 1. Obtain the game's Preset ID from here (if you don't already know what it is):
# https://docs.google.com/spreadsheets/d/1PbIPVA4NpFEXs1zk249aR3FSuBTY3r-ajpTq3dP3GnQ/edit#gid=490971147
# Alternatively, you may know what it is from doing a game save backup from the WiiU and then inspecting 
# E.g. for Super Metroid E-PAL, it is 0x1042. Set the following variable to the value:
$presetid = 0x1042

# 2. Obtain the SNES ROM name from here:
# https://github.com/wheatevo/wiiu-vc-extractor/blob/master/WiiuVcExtractor/snesromnames.csv
# E.g. for Super Metroid E-PAL, it is "WUP-JAJP"
# Alternatively, you may know what it is from doing a game save backup from the
# WiiU and then inspecting the 5th and 6th bytes (remembering it is little endian) in a hex editor.
# Set the following variable to the value:
$romname = "WUP-JAJP"

# 3. Set the following to the path to your savedata.bin file
# Yes, I could have slapped a GUI on, but it wasn't worth the effort!
# Set the following variable to the value:
$savedatapath = "D:\wiiu\backups\000100014a415650\3\savedata.bin"


# OK, off we go...
# Get the data from the source file as a byte array
$bytesvc = [System.IO.File]::ReadAllBytes($savedatapath)

# Prefix it with 48 0ed out byutes
$newbytesvc = [System.Byte[]]::CreateInstance([System.Byte], 48) + $bytesvc

# Fill in the compulsory values and the preset id (leaving the checksum 0 for now)
$newbytesvc[0] = 0x01
$newbytesvc[4] = $presetid -band 0xFF
$newbytesvc[5] = $presetid -shr 0x08
$newbytesvc[16] = 0xC1
$newbytesvc[17] = 0x35
$newbytesvc[18] = 0x86
$newbytesvc[19] = 0xA5
$newbytesvc[20] = 0x65
$newbytesvc[21] = 0xCB
$newbytesvc[22] = 0x94
$newbytesvc[23] = 0x2C

# Calculate the checksum across the whole "file"
$checksum = 0x0
for( $i = 0; $i -lt $newbytesvc.Count; $i++ ) {
    $checksum += $newbytesvc[$i]
}
$checksum = $checksum % 0x10000 - 1

# Pop the checksum in the "file" (LE)
$newbytesvc[2] = $checksum -band 0xFF
$newbytesvc[3] = $checksum -shr 0x08

# Spit it out to a file
$outputfile = ( Split-Path $savedatapath ).ToString() + "\" + $romname + ".ves"
[System.IO.File]::WriteAllBytes( $outputfile , $newbytesvc )
"File saved to ""{0}""." -f $outputfile
