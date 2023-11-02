## Globals and constants
## =====================

import std/[os, times]

const dateFormat*: string = "yyyy-MM-dd" ## Date format used by the json file


# OS-specific:
let
    tempDir: string = getTempDir() ## OS-specific temporary directory
    tempWorkingDir*: string = tempDir & "temp-topicdocchanger-files/" ## Temporary directory used by this program
    tempWorkingUnzipped*: string = tempWorkingDir & "unzipped/" ## Temporary directory with unzipped template .docx file
    tempUnzippedDocumentXml*: string = tempWorkingUnzipped & "word/document.xml" ## Path to `document.xml` file in the temporary directory

var
    sourceDocxFile*: string ## Source .docx file
    outputDirectory*: string ## Output path, where all generated files will go
    outputFileName*: string ## Output name (will be: `sourceDocxFile & "_" & DATE & ".docx"`)

    dateFromRaw*: string ## Has to be converted
    dateTillRaw*: string ## Has to be converted

    dateFrom*: DateTime ## Has to be set by `convertDates`
    dateTill*: DateTime ## Has to be set by `convertDates`

proc setSourceDocument*(filepath: string) {.raises: [OSError].} =
    ## Sets the source document, errors when it is not found
    if not filepath.fileExists():
        raise OSError.newException("Source document file '" & filepath & "' does not exist. Are you sure you gave the correct path?")
    sourceDocxFile = filepath

proc convertDates*() =
    ## Converts `dateFromRaw` to `dateFrom` and `dateTillRaw` to `dateTill`
    dateFrom = parse(dateFromRaw, dateFormat)
    dateTill = parse(dateTillRaw, dateFormat)



