#!/bin/bash

BUILD="build"
NIMBLE="nimble build -d:release"

$NIMBLE          && mv "docchanger"     $BUILD
$NIMBLE -d:mingw && mv "docchanger.exe" $BUILD
