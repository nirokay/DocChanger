## Types
## =====
##
## Includes all global types (basically only the `Replacement` object)

import std/[tables, options]

type
    SearchStrings* = object
        starting*: Option[string] = some "${"
        ending*: Option[string] = some "}"

        participant_prefix*: Option[string] = some "PARTICIPANTS_"
        date*: Option[string] = some "INSERT_DATE"

    DateRange* = object
        starting*, ending*: string = "yyyy-MM-dd"
        starting_weekday*: int = 0 ## Week starts at Monday, 0 means not specified - pick the fist-valid day
        day_interval*: int = 7

    Replacement* = object
        document_output_directory*: Option[string] = some "./output/"
        document_source_filename*: Option[string] = some "input_document.docx"
        document_date_range*: Option[DateRange] = some DateRange()

        participants*: Option[Table[string, seq[string]]]

        name_separator*: Option[string] = some ", "
        search_strings*: Option[SearchStrings] = some SearchStrings()

var
    replacement*: Replacement = Replacement()
    emptyTable: Table[string, seq[string]]
replacement.participants = some emptyTable

