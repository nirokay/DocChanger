# Package

version       = "1.1.0"
author        = "nirokay"
description   = "Replaces specific xml text in .docx files."
license       = "GPL-3.0-only"
bin           = @["docchanger"]

# Include required compile-time files

installExt    = @["template"]

# Dependencies

requires "nim >= 2.0.0"
requires "zippy"
