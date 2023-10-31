import std/[os, parseopt, strutils, strformat, options]
import docchangerpkg/[constants, errors, zipstuff, types, confirmation]
import docchangerpkg/datachanger
import package


when isMainModule:
    proc main() =
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
            var lines: seq[string] = @[
                &"{projectName} - {projectVersion}",
                projectDescription,
                "by " & projectAuthors.join(", ") & &" - distributed as {projectLicence}",
                projectSource,
                "\nFlags:",
            ]
            for cmd in commands:
                lines.add(
                    alignLeft("-" & cmd.nameShort & ", --" & cmd.nameLong, 25) & cmd.desc
                )

            echo lines.join("\n")
            quit QuitSuccess
        )

        newCommand("version", "v", "Prints the program version.", proc(_: string) =
            echo &"{projectName} - {projectVersion}"
            quit QuitSuccess
        )

        # Parse cmd args:
        var runInteractivePrompt: bool = paramCount() == 0

        # Parse commandline args:
        if not runInteractivePrompt:
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

        if sourceDocxFile == "":
            sourceDocxFile = get replacement.document_source_filename
        unzipToTempDir(sourceDocxFile)

        try:
            writeDocumentForEveryDate()
        except CatchableError as e:
            raise DocumentChangerError.newException(
                "Failed to generate/write document.\n" &
                "Details: " & e.msg
            )

    var successful: bool = false
    try:
        main()
        successful = true
    except CatchableError as e:
        echo e.msg
    except Defect as e:
        echo e.msg
    finally:
        if successful: exit QuitSuccess
        else: exit QuitFailure
