import std/[options, tables, strutils, strformat, times, os]
import constants, types, zipstuff, jsonimport, confirmation

var generationStatus: tuple[successes, failures: int, failsAt: seq[string]]
proc addSuccess() =
    generationStatus.successes.inc()
proc addFailure(date: string) =
    generationStatus.failures.inc()
    generationStatus.failsAt.add(date)

proc setDatesFinal() =
    ## Get starting date to requested weekday
    if dateFrom == dateTill: return
    var requestedDay: WeekDay
    # Amazing code:
    let weekdayNumber: int = get(replacement.document_date_range).starting_weekday
    case weekdayNumber:
    # Weekdays:
    of 1: requestedDay = dMon
    of 2: requestedDay = dTue
    of 3: requestedDay = dWed
    of 4: requestedDay = dThu
    of 5: requestedDay = dFri
    of 6: requestedDay = dSat
    of 7: requestedDay = dSun
    # Ignore weekday:
    of 0:
        echo &"Setting starting weekday to the starting date ({dateFrom.weekday})!"
        return
    # Complain and shame the user, ask for consent, then ignore the weekday:
    else:
        consentOrDie(
            &"Got invalid weekday number ({weekdayNumber}), expected range from 0 to 7 (Ignore: 0 ; Monday: 1 ; ... Sunday: 7)!\n" &
            &"Was this a mistake? Continue as if it was set to ignore? Starting weekday will be set to {dateFrom.weekday}.",

            &"Continuing with {dateFrom.weekday} as beginning weekday.",

            "Aborting..."
        )
        return

    while dateFrom.weekday != requestedDay:
        dateFrom += days(1)
    echo &"Setting starting weekday to {dateFrom.weekday}!"


iterator getDateForDocument*(): DateTime =
    setDatesFinal()
    echo "Beginning generation..."
    let interval: int = get(replacement.document_date_range).day_interval
    while dateFrom <= dateTill:
        yield dateFrom
        dateFrom += days(interval)

# Read json file:
parseJsonToReplacement()

# Read document.xml file:
var xmlTemplate: string
proc readDocumentXmlFile() =
    try:
        xmlTemplate = readFile(tempUnzippedDocumentXml)
    except IOError:
        echo "Could not read document.xml file."
        consentOrDie("Continue with empty data?", "Continuing with empty document.xml content.")
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
    readDocumentXmlFile()
    if not outputDirectory.dirExists():
        outputDirectory.createDir()
    try:
        outputFileName = sourceDocxFile.strip().split(".")[0..^2].join(".")
    except Defect:
        raise ValueError.newException("Failed to split source document file name. Please make sure it is named in this pattern: '[document name].[file extention]'")

    for date in getDateForDocument():
        var xml: string = xmlTemplate

        # Change date on document:
        let
            dateFileContent: string = date.format("dd") & "." & date.format("MM") & "." & date.format("yyyy")
            dateFileName: string = date.format("yyyy-MM-dd")
        print("🗘 Generating document " & dateFileName)
        xml = xml.replace(dateReplace.this, dateFileContent)

        # Change participants:
        for i in replaceStrings:
            xml = xml.replace(i.this, i.with)

        # Write to file and assemble zip file:
        try:
            tempUnzippedDocumentXml.writeFile(xml)
        except IOError:
            addFailure(dateFileName)
            print("🗙     Failed to open and write to '" & tempUnzippedDocumentXml & "'! Skipping...\n")
            continue
        print("⇅   Assembling document for date " & dateFileName)

        try:
            assembleDocumentFile(&"{outputDirectory}/{outputFileName}_{dateFileName}.docx")
        except CatchableError as e:
            addFailure(dateFileName)
            print(&"🗙     Failed to assemble document for date {dateFileName}\n\tDetails: {e.msg}\n")
            continue
        print "✓     Finished document for date " & dateFileName & "\n"
        addSuccess()

    print("✓ Completed task\n")

    # Print stats:
    echo @[
        "Successes: " & $generationStatus.successes,
        "Failures:  " & $generationStatus.failures
    ].join("\n")
    if generationStatus.failsAt.len() != 0:
        echo "Failed at: " & generationStatus.failsAt.join(", ")

