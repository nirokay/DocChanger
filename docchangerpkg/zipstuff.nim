## ZipStuff
## ========
##
## Handles all things zip. Unzips and assembles zip files.

import std/[os]
import constants, errors
import zippy/[ziparchives]



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


proc unzipToTempDir*(filepath: string) {.raises: [ZipUnzipError, IOError, TempDirAccessError, TempDirCreationError].} =
    ## Unzips the .docx file to temporary directory

    # 1,000,000 IQ move to ensure the directory is empty:
    deleteTempDir()
    createTempDir()

    if not sourceDocxFile.fileExists():
        raise IOError.newException("Could not find a file at '" & sourceDocxFile & "'!")

    try:
        extractAll(sourceDocxFile, tempWorkingUnzipped)
    except IOError, OSError, ZippyError:
        raise ZipUnzipError.newException("Failed to extract zip contents to '" & tempWorkingUnzipped & "'! Do you have permissions?")


proc assembleDocumentFile*(outputDocument: string = "document.out.docx") {.raises: [OSError, IOError].} =
    ## Assembles the .docx file from the temporary directory
    try:
        createZipArchive(tempWorkingUnzipped, outputDocument)
    except OSError:
        raise OSError.newException("Could not access temporary directory '" & tempWorkingUnzipped & "'!")
    except IOError:
        raise IOError.newException("Could not create file with name '" & outputDocument & "'. Does it already exist?")
    except ZippyError:
        raise ZipWriteError.newException("Could not write .docx file.")
