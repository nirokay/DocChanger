import std/[tables, options]

type
    SearchStrings* = object
        starting*: Option[string] = some "${"
        ending*: Option[string] = some "}"

        participant_prefix*: Option[string] = some "PARTICIPANTS_"
        date*: Option[string] = some "INSERT_DATE"

    Replacement* = object
        document_output_directory*: Option[string] = some "./output/"
        document_source_filename*: Option[string] = some "input_document.docx"
        document_date_range*: Option[Table[string, string]] = some toTable {
            "starting": "yyyy-MM-dd",
            "ending": "yyyy-MM-dd"
        }

        participants*: Option[Table[string, seq[string]]]

        name_separator*: Option[string] = some ", "
        search_strings*: Option[SearchStrings] = some SearchStrings()

var
    replacement*: Replacement = Replacement()
    emptyTable: Table[string, seq[string]]
replacement.participants = some emptyTable

