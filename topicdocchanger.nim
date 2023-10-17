import topicdocchanger/[constants, zipstuff]

const sourcedocument {.strdefine.}: string = "unspecified-document.docx" #! Placeholder, will be interactive later on

setSourceDocument(sourcedocument)
sourceDocxFile.unzipToTempDir()

assembleDocumentFile()
