# DocChanger

A highly specific tool developed for a single, niche purpose - change specific
substrings in `.docx` files.

The original intent for this tool is to generate ~50 documents (for
every week) for meetings with the only thing changing between them being
the date and participants.

## How does it work?

Every `.docx` file is just a renamed `.zip` archive. This program unzips
the document to a temporary directory (Linux: `/tmp/temp-topicdocchanger-files`)
and modifies the `word/document.xml` file. After this is completed, the file is
zipped up and the file extention is changed to `.docx` again.

This tool is pretty flexible, you can modify the substrings it replaces in
the `document_data.json` config file. This file needs to be located in the
current directory (most of the times: right next to the executable).

If this file is not found, the program generates a template json file
(template can be found at `./templates/document_data.json.template`).

## Default behaviour

By default the json will make the program search for the following substrings:

* `${INSERT_DATE}` to insert the (weekly) date (hard coded to Thursday,
  **soon also configurable with json**)

* `${PARTICIPANTS_FEMALE}` female participants

* `${PARTICIPANTS_MALE}` male participants

* `${PARTICIPANTS_DIVERSE}` i have officially gone WOKE!!!! (sorry mom and dad)

* `${PARTICIPANTS_INTERN}` interns (the fourth gender)

The `${}` can be changed in the json with the `.search_strings.starting` and
`.search_strings.ending` fields.

`PARTICIPANT_` can be changed with `.search_strings.participants_prefix` and
`FEMALE`, `MALE`, `DIVERSE`, `INTERN` are the table values in the
`.participants` table/array.

## JSON config file data types

For documentation see the [json file structure document](./templates/README.md).

For an example, see `./templates/document_data.json.template`

## Dependencies

The binary should not have any external dependencies, as everything
is implemented in pure Nim and is fully portable.

## Compiling from source

**Dependencies:**

* Nim (version 2.0 or higher`*[1]`) and Nimble

* bash (Optional: only used for automatic building)

> `*[1]` source code should be backwards-compatible to at minimum `1.6.x`
> Nim versions by modifying the `.nimble` file to accept older Nim versions

## Troubleshooting

Document editors are weird. Sometimes a string is randomly interrupted and
split into multiple parts in the xml-file. There is probably a performance
reason for it or something, but it is bad for us in our case...

### Program fails to replace a specific substring

1. Unzip the source `.docx` file.

2. Navigate to `./$DOCUMENT/word/document.xml`

3. Open this file and search for a part of the substring, that failed to be
4. replaced. The raw xml is horrible, as it is most likely all one big line.
5. Using an editor, that can format xml is recommended.

6. Place all broken-up substrings together, so they form the correct
7. replacement string again.

8. Optional: Delete empty xml blocks (if you cut out and pasted from one block
9. to another)

10. Re-zip the items and change the `.zip` to a `.docx`.

   **Important:** Only zip the file contents directly, not the extracted
   directory itself. That would make most applications handle it as a
   corrupted/incorrect file.

### Program fails to parse the config json file

Make sure the json is formatted correctly, common mistakes may include:

* Trailing or missing commas - commas separate array/table values

* Unquoted values - all values must be inside quotes (like this:
  `"index": "value"`), unless it is a number (-> `"index": 5`).

To ensure correct format, see the [format section](#json-config-file-data-types)
above or look at the example at `./templates/document_data.json.template`.
