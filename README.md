# DocChanger

A highly specific tool developed for a single, niche purpose - change specific substrings in `.docx` files.

The original intent for this tool is to generate ~50 documents (for every week) for meetings with the only thing changing between them being the date and participants.

## How does it work?

Every `.docx` file is just a renamed `.zip` archive. This program unzips the document to a temporary directory (Linux: `/tmp/temp-topicdocchanger-files`) and modifies the `word/document.xml` file. After this is completed, the file is zipped up and the file extention is changed to `.docx` again.

This tool is pretty flexible, you can modify the substrings it replaces in the `document_data.json` config file. This file needs to be located in the current directory (most of the times: right next to the executable).

If this file is not found, the program generates a template json file (template can be found at `./templates/document_data.json.template`).

## Default behaviour

By default the json will make the program search for the following substrings:

* `${INSERT_DATE}` to insert the (weekly) date (hard coded to Thursday, **soon also configurable with json**)

* `${PARTICIPANTS_FEMALE}` female participants

* `${PARTICIPANTS_MALE}` male participants

* `${PARTICIPANTS_DIVERSE}` i have officially gone WOKE!!!! (sorry mom and dad)

* `${PARTICIPANTS_INTERN}` interns (the fourth gender)

The `${}` can be changed in the json with the `.search_strings.starting` and `.search_strings.ending` fields.

`PARTICIPANT_` can be changed with `.search_strings.participants_prefix` and `FEMALE`, `MALE`, `DIVERSE`, `INTERN` are the table values in the `.participants` table/array.

## JSON config file data types

This is the json config file structure (roughly implemented in Nim, because type safety!):

```nim
import std/tables
type JsonConfig = object
    # Path to directory, where assembled documents will be put:
    document_output_directory*: string = ".out"
    # Source document (with substrings, that will be replaced):
    document_source_filename*: string = "example_document.docx"

    # Date range to create documents:
    document_date_range*: Table[string, string] = toTable {
        "starting": "yyyy-MM-dd",
        "ending": "yyyy-MM-dd"
    }

    # Participant data:
    participants*: Table[string, seq[string]] = toTable {
        "FEMALE": @["person0"],
        "MALE": @["person1", "person2"]
    }

    # Used to separate names in participants listing:
    name_separator*: string = ", "

    # To-replace substrings:
    search_strings*: Table[string, string] = toTable {
        "starting": "${",
        "participants_prefix": "PARTICIPANTS_",
        "date": "INSERT_DATE",
        "ending": "}"
    }
```

For an example, see `./templates/document_data.json.template`

## Troubleshooting

Document editors are weird. Sometimes a string is randomly interrupted and split into multiple parts in the xml-file. There is probably a performance reason for it or something, but it is bad for us in our case...

**If the program fails to replace a specific substring:**

1. Unzip the source `.docx` file.

2. Navigate to `./$DOCUMENT/word/document.xml`

3. Open this file and search for a part of the substring, that failed to be replaced. The raw xml is horrible, as it is most likely all one big line. Using an editor, that can format xml is recommended.

4. Place all broken-up substrings together, so they form the correct replacement string again.

5. Optional: Delete empty xml blocks (if you cut out and pasted from one block to another)
