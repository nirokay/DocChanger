type
    TopicDocChangerError* = object of CatchableError

    TempDirError* = object of OSError
    TempDirCreationError* = object of TempDirError
    TempDirAccessError* = object of TempDirError

    ZipError* = object of IOError
    ZipAccessError* = object of ZipError
    ZipUnzipError* = object of ZipError
