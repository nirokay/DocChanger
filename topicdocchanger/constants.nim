import std/[os]

# OS-specific:
let
    tempDir: string = getTempDir()
    tempWorkingDir*: string = tempDir & "temp-topicdocchanger-files/"
    tempWorkingUnzipped*: string = tempWorkingDir & "unzipped/"

# .docx file in temporary directory:
var sourceDocxFile*: string

proc setSourceDocument*(filepath: string) {.raises: [OSError].} =
    ## Sets the source document
    if not filepath.fileExists():
        raise OSError.newException("Source document file '" & filepath & "' does not exist. Are you sure you gave the correct path?")
    sourceDocxFile = filepath



