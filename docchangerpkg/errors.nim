## Custom error objects
## ====================

type
    DocumentChangerError* = object of CatchableError ## Generic error when creating document for every date fails

    TempDirError* = object of OSError ## Generic temp dir error
    TempDirCreationError* = object of TempDirError ## Failed to create tempo dir
    TempDirAccessError* = object of TempDirError ## Failed to read/write to temp dir

    ZipError* = object of IOError ## Generic error for zip files
    ZipWriteError* = object of ZipError ## Could not create/write to the modified document archive
    ZipUnzipError* = object of ZipError ## Could not unzip archive to temp directory

    JsonFileNotFoundError* = object of OSError ## Json config could not be located
    JsonFormatError* = object of IOError ## Badly formatted json

    TimeTravelError* = object of ValueError ## Invalid date range
