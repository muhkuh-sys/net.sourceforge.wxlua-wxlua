import argparse
import os
import os.path
import shutil
import string
import subprocess

tParser = argparse.ArgumentParser(description='Copy wxWidgets libraries.')
tParser.add_argument('base', help='The base folder of the installation.')
atArgs = tParser.parse_args()

# Construct the path to wx-config.
strwxConfigPath = os.path.join(atArgs.base, 'bin', 'wx-config')
if os.path.isfile(strwxConfigPath) is not True:
    raise Exception('Could not find wx-config.')

# Get the expected name of the scintilla library.
strScintillaExpected = None
strOutput = subprocess.check_output([strwxConfigPath, '--libs', 'scintilla'])
astrOutput = string.split(strOutput)
for strOpt in astrOutput:
    iHasScintilla = string.find(strOpt, 'scintilla')
    if iHasScintilla != -1:
        strScintillaExpected = strOpt

if strScintillaExpected is None:
    raise Exception('Failed to determine the expected scintilla library name.')

# Does the expected library already exist?
if os.path.isfile(strScintillaExpected) is not True:
    # No, correct the name.

    # Now find the real scintilla library name.
    strScintillaExisting = None
    strLibraryPath = os.path.dirname(strScintillaExpected)
    for strRoot, atDirs, atFiles in os.walk(strLibraryPath):
        for strFile in atFiles:
            iHasScintilla = string.find(strFile, 'scintilla')
            if iHasScintilla != -1:
                if strScintillaExisting is not None:
                    raise Exception('Found more than one scintilla library!')
                strScintillaExisting = os.path.join(strRoot, strFile)

    shutil.copyfile(strScintillaExisting, strScintillaExpected)
