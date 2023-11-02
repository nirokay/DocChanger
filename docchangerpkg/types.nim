## Types
## =====
##
## Includes all global types (basically only the `Replacement` object).
## Objects have default values, which means the json does not *require* all fields, but they should still be in there for maximal customization.

import std/[tables, options]

type
    SearchStrings* = object ## `search_strings` json object
        starting*: Option[string] = some "${" ## Start of the replacement string identifier
        ending*: Option[string] = some "}" ## End of the replacement string identifier

        participant_prefix*: Option[string] = some "PARTICIPANTS_" ## Replacement identifier
        date*: Option[string] = some "INSERT_DATE" ## Replacement identifier for the date

    DateRange* = object ## `document_date_range` json field
        starting*, ending*: string = "yyyy-MM-dd" ## Starting and ending dates in, obviously, `yyyy-MM-dd` format
        starting_weekday*: int = 0 ## Week starts at Monday, 0 means not specified - pick the fist-valid day
        day_interval*: int = 7 ## Repeat generation every `x` days

    Replacement* = object ## Entire replacement object - parsed from json at runtime
        document_output_directory*: Option[string] = some "./output/" ## Output directory for generated files
        document_source_filename*: Option[string] = some "input_document.docx" ## Template .docx file, that will be used to generate documents
        document_date_range*: Option[DateRange] = some DateRange()

        participants*: Option[Table[string, seq[string]]] ## Values to replace -> "${`participant_prefix` & `index`} will become `value`"

        name_separator*: Option[string] = some ", " ## Separators for participant names
        search_strings*: Option[SearchStrings] = some SearchStrings()

var
    replacement*: Replacement = Replacement() ## Global replacement object
    emptyTable: Table[string, seq[string]]

# Witchcraft to init the table: (great code)
replacement.participants = some emptyTable

