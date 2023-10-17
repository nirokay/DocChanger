import std/[os, strutils]
import constants, errors
import zip/[zipfiles]

const outputDocument {.strdefine.}: string = "document.out.docx"

proc createTempDir*() {.raises: TempDirCreationError.} =
    ## Creates a temporary directory
    if tempWorkingDir.dirExists(): return
    try:
        tempWorkingDir.createDir()
    except CatchableError as e:
        raise TempDirCreationError.newException(
            "Failed to create temporary directory at '" & tempWorkingDir & "'!\n" &
            "Details: " & e.msg
        )

proc deleteTempDir*() {.raises: TempDirAccessError.} =
    ## Deletes the temporary directory along with its contents
    if not tempWorkingDir.dirExists(): return
    try:
        tempWorkingDir.removeDir()
    except CatchableError as e:
        raise TempDirAccessError.newException(
            "Failed to delete temporary directory at '" & tempWorkingDir & "'!\n" &
            "Details: " & e.msg
        )

proc unzipToTempDir*(filepath: string) {.raises: [ZipAccessError, ZipUnzipError, TempDirAccessError, TempDirCreationError].} =
    ## Unzips the .docx file to temporary directory

    # 1,000,000 IQ move to ensure the directory is empty:
    deleteTempDir()
    createTempDir()

    var zip: ZipArchive
    try:
        if not zip.open(sourceDocxFile, fmRead):
            raise ZipAccessError.newException("Failed to access .docx file as zip archive.")
    except OSError:
        raise ZipAccessError.newException("Failed to access file '" & sourceDocxFile & "'! Does file exist?")

    try:
        zip.extractAll(tempWorkingUnzipped)
    except IOError, OSError:
        raise ZipUnzipError.newException("Failed to extract zip contents to '" & tempWorkingUnzipped & "'! Do you have permissions?")


proc assembleDocumentFile*() {.raises: [ZipAccessError, IOError, OSError].} =
    var zip: ZipArchive
    if not zip.open(outputDocument, fmWrite):
        raise ZipAccessError.newException("Could not write to new zip file.")

    var currentFile: string
    try:
        for file in walkDirRec(tempWorkingUnzipped):
            currentFile = file
            currentFile.removePrefix(tempWorkingUnzipped)
            zip.addFile(currentFile, file)
    except OSError, IOError:
        raise IOError.newException("Could not access a file in '" & tempWorkingUnzipped & "' ('" & currentFile & "')!")

    zip.close()

