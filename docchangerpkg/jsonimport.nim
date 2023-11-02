import std/[os, json as jsonClass, options, tables, times]
import types, errors, constants

const
    jsonFile*: string = "document_data.json"
    jsonExampleFileContent*: string = readFile("templates/" & jsonFile & ".template")

proc parseJsonToReplacement*() {.raises: [TimeTravelError, JsonFileNotFoundError, JsonParsingError, JsonFormatError, OSError, ValueError, IOError,].} =
    var json: JsonNode

    try:
        json = jsonFile.readFile().parseJson()

    except IOError, OSError:
        raise JsonFileNotFoundError.newException("Did not find json data file. Expected at '" & getCurrentDir() & "'.")

    except JsonParsingError as e:
        raise JsonParsingError.newException(
            "Json file could not be parsed. Is it formatted correctly?\n" &
            "Details: " & e.msg
        )
    finally:
        if not jsonFile.fileExists():
            echo "Generating example json file at '" & getCurrentDir() & jsonFile & "'."
            jsonFile.writeFile(jsonExampleFileContent)


    try:
        replacement = json.to(Replacement)
    except JsonKindError as e:
        raise JsonFormatError.newException("Failed to bind json to 'Replacement' object. Incorrect json format?\nDetails: " & e.msg)

    # Assign global values:
    sourceDocxFile = get replacement.document_source_filename
    outputDirectory = get replacement.document_output_directory

    # Parse date from json and assign to global vars:
    let dates: DateRange = get replacement.document_date_range
    try:
        dateFromRaw = dates.starting
        dateTillRaw = dates.ending
    except KeyError as e:
        raise JsonParsingError.newException(
            "Failed to find table key, please refer to the example json file for correct format!\n" &
            "Details: " & e.msg
        )

    # Convert and validate date ranges:
    convertDates()
    if dateFrom > dateTill:
        raise TimeTravelError.newException(
            "Failed to travel in time - ending date lies in the past compared to the starting date. " &
            "Were the values mixed up?"
        )
