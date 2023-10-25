import std/[options, tables, strutils, strformat, times, os]
import constants, types, zipstuff, jsonimport, confirmation


# Get starting day to requested day:
proc setDatesFinal() =
    if dateFrom != dateTill: return
    let requestedDay: WeekDay = dThu
    convertDates()
    while dateFrom.weekday != requestedDay:
        dateFrom += days(1)

iterator getDateForDocument*(): DateTime =
    setDatesFinal()
    while dateFrom <= dateTill:
        yield dateFrom
        dateFrom += days(7)

# Read json file:
parseJsonToReplacement()

# Read document.xml file:
var xmlTemplate: string
proc readDocumentXmlFile() =
    try:
        xmlTemplate = readFile(tempUnzippedDocumentXml)
    except IOError:
        echo "Could not read document.xml file."
        stdout.write("Continue with empty data? [y/N] ")
        stdout.flushFile()
        case stdin.readLine().toLower():
        of "y":
            echo "Continuing..."
        else:
            echo "Quitting..."
            exit QuitFailure
        xmlTemplate = ""

proc namesFormatted*(names: seq[string]): string =
    result = names.join(get replacement.name_separator)
    if result == "":
        result = "/"

var replaceStrings: seq[tuple[this, with: string]]
let searchStrings: SearchStrings = get replacement.search_strings
for i, v in get replacement.participants:
    let toReplace: string = block:
        searchStrings.starting.get() &
        searchStrings.participant_prefix.get() &
        i &
        searchStrings.ending.get()

    replaceStrings.add((
        this: toReplace,
        with: v.namesFormatted()
    ))

var dateReplace: tuple[this, with: string] = (
    this: searchStrings.starting.get() & searchStrings.date.get() & searchStrings.ending.get(),
    with: "" # Will get reassigned for each date
)

var empty: string = ""
proc print(message: string) =
    stdout.write(empty)
    stdout.flushFile()
    stdout.write("\r" & message)
    stdout.flushFile()

    empty = repeat(' ', message.len())

proc writeDocumentForEveryDate*() =
    setDatesFinal()
    readDocumentXmlFile()
    if not outputDirectory.dirExists():
        outputDirectory.createDir()
    outputFileName = sourceDocxFile.strip().split(".")[0..^2].join(".")

    for date in getDateForDocument():
        var xml: string = xmlTemplate

        # Change date on document:
        let
            dateFileContent: string = date.format("dd") & "." & date.format("MM") & "." & date.format("yyyy")
            dateFileName: string = date.format("yyyy-MM-dd")
        print("Generating document " & dateFileName)
        xml = xml.replace(dateReplace.this, dateFileContent)

        # Change participants:
        for i in replaceStrings:
            xml = xml.replace(i.this, i.with)

        # Write to file and assemble zip file:
        try:
            tempUnzippedDocumentXml.writeFile(xml)
        except IOError:
            echo "Failed to open and write to '" & tempUnzippedDocumentXml & "'! Skipping..."
        print("  Assembling document for date " & dateFileName)

        assembleDocumentFile(&"{outputDirectory}/{outputFileName}_{dateFileName}.docx")
        print "    Finished document for date " & dateFileName & "\n"

    print("Completed task\n")

