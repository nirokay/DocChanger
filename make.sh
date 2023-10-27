#!/bin/bash

BUILD="build"

nimble build && mv "docchanger" $BUILD
nimble build -d:mingw && mv "docchanger.exe" $BUILD
