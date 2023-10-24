import std/[os, json as jsonClass, options, tables]
import types, errors, constants

const
    jsonFile*: string = "document_data.json"
    jsonExampleFileContent*: string = readFile("templates/" & jsonFile & ".template")

proc parseJsonToReplacement*() {.raises: [JsonFileNotFoundError, JsonParsingError, JsonFormatError, OSError, ValueError, IOError].} =
    var json: JsonNode

    try:
        json = jsonFile.readFile().parseJson()

    except IOError, OSError:
        raise JsonFileNotFoundError.newException("Did not find json data file. Expected at '" & getCurrentDir() & jsonFile & "'.")

    except JsonParsingError as e:
        raise JsonParsingError.newException(
            "Json file could not be parsed. Is it formatted correctly?\n" &
            "Details: " & e.msg
        )
    finally:
        if not jsonFile.fileExists():
            echo "Generating example json file."
            jsonFile.writeFile(jsonExampleFileContent)


    try:
        replacement = json.to(Replacement)
    except JsonKindError as e:
        raise JsonFormatError.newException("Failed to bind json to 'Replacement' object. Incorrect json format?\nDetails: " & e.msg)

    # Assign global values:
    sourceDocxFile = get replacement.document_source_filename
    outputDirectory = get replacement.document_output_directory

    try:
        let dates: Table[string, string] = get replacement.document_date_range
        dateFromRaw = dates["starting"]
        dateTillRaw = dates["ending"]
    except KeyError as e:
        raise JsonParsingError.newException(
            "Failed to find table key, please refer to the example json file for correct format!" &
            "Details: " & e.msg
        )

    echo json.fields["participants"]

    # Participants:
    replacement.participants = some json.fields["participants"].to(Table[string, seq[string]])


