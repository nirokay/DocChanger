import std/[os]

# OS-specific:
let
    tempDir: string = getTempDir()
    tempWorkingDir*: string = tempDir & "temp-topicdocchanger-files/"
    tempWorkingUnzipped*: string = tempWorkingDir & "unzipped/"

var
    sourceDocxFile*: string
    sourceDocumentIsSet*: bool = false

proc setSourceDocument*(filepath: string) {.raises: [OSError].} =
    ## Sets the source document
    if not filepath.fileExists():
        raise OSError.newException("Source document file '" & filepath & "' does not exist. Are you sure you gave the correct path?")
    sourceDocxFile = filepath
    sourceDocumentIsSet = true
