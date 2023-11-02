# JSON file structure

This is the json config file structure (roughly implemented in Nim, because
type safety!):

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
