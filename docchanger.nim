import std/[os, parseopt, strutils, strformat, macros, options]
import docchanger/[constants, jsonimport, errors, zipstuff, types]
import package


when isMainModule:
    proc interactivePrompt() =
        # Macro to make code go brrrrrr:
        macro `?`(question: string, variable: var string) = quote("@") do:
            stdout.write(@question & ": ")
            let response: string = stdin.readLine()
            @variable = response

        # Welcome text:
        echo "Interactive prompt.\nPlease provide valid information to the following questions to continue with execution.\n"

        # Prompts:
        "Template/Input .docx file path" ? sourceDocxFile
        "Path to output directory" ? outputDirectory
        &"Generate from [Date in format '{dateFormat}']" ? dateFromRaw
        &"Generate until [Date in format '{dateFormat}']" ? dateTillRaw

    type Command = object
        nameLong*, nameShort*, desc*: string
        call*: proc(value: string)

    var commands: seq[Command]
    proc newCommand(long, short, desc: string, call: proc(value: string)) =
        commands.add(
            Command(
                nameLong: long,
                nameShort: short,
                desc: desc,
                call: call
            )
        )

    newCommand("help", "h", "Prints this help message.", proc(_: string) =
        var lines: seq[string]
        for cmd in commands:
            lines.add(
                alignLeft("-" & cmd.nameShort & ", --" & cmd.nameLong, 25) & cmd.desc
            )

        echo lines.join("\n")
        quit QuitSuccess
    )

    newCommand("version", "v", "Prints the program version.", proc(_: string) =
        echo projectVersion
        quit QuitSuccess
    )

    # Parse cmd args:
    var runInteractivePrompt: bool = paramCount() == 0

    # Parse json data from json file
    if jsonFile.fileExists():
        parseJsonToReplacement()

    # Parse commandline args:
    elif not runInteractivePrompt:
        var p: OptParser = initOptParser()
        for kind, key, value in p.getopt():
            case kind:
            # Source document cmd arg:
            of cmdArgument:
                sourceDocxFile = key
            # Flags:
            of cmdLongOption, cmdShortOption:
                for cmd in commands:
                    if key in [cmd.nameLong, cmd.nameShort]: cmd.call(value)
            of cmdEnd:
                break
        quit QuitSuccess

    # Run interactive prompt, when no cmd args given (for example, executing by double-clicking):
    else:
        interactivePrompt()

    if sourceDocxFile == "":
        sourceDocxFile = get replacement.document_source_filename
    unzipToTempDir(sourceDocxFile)

    import docchanger/datachanger
    try:
        writeDocumentForEveryDate()
    except CatchableError as e:
        raise DocumentChangerError.newException(
            "Failed to generate/write document.\n" &
            "Details: " & e.msg
        )
