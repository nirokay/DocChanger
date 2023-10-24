import std/[os, times]

const dateFormat*: string = "yyyy-MM-dd"


# OS-specific:
let
    tempDir: string = getTempDir()
    tempWorkingDir*: string = tempDir & "temp-topicdocchanger-files/"
    tempWorkingUnzipped*: string = tempWorkingDir & "unzipped/"
    tempUnzippedDocumentXml*: string = tempWorkingUnzipped & "word/document.xml"

var
    sourceDocxFile*: string
    outputDirectory*: string
    outputFileName*: string

    dateFromRaw*: string ## Has to be converted
    dateTillRaw*: string ## Has to be converted

    dateFrom*: DateTime ## Has to be set by `convertDates`
    dateTill*: DateTime ## Has to be set by `convertDates`

proc setSourceDocument*(filepath: string) {.raises: [OSError].} =
    ## Sets the source document
    if not filepath.fileExists():
        raise OSError.newException("Source document file '" & filepath & "' does not exist. Are you sure you gave the correct path?")
    sourceDocxFile = filepath

proc convertDates*() =
    dateFrom = parse(dateFromRaw, dateFormat)
    dateTill = parse(dateTillRaw, dateFormat)



