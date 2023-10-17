import topicdocchanger/[constants, zipstuff]

const sourcedocument {.strdefine.}: string = "unspecified-document.docx"

setSourceDocument(sourcedocument)
sourceDocxFile.unzipToTempDir()

assembleDocumentFile()
