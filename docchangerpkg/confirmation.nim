## Confirmations
## =============
##
## This module handles user input - consenting or dissenting to something.

import std/[strutils]

type Confirmation* = enum
    confirmYes, confirmNo, confirmQuestionable

proc exit*(code: int) =
    ## Same as `quit(code: int)`, but waits for keyboard input before actually terminating the process
    echo "\nProgram terminated, press ENTER to close.\n"
    discard stdin.readLine()
    quit(code)



proc getYesNoPrompt(default: Confirmation): string =
    result = "[y/n]"
    case default:
    of confirmYes:
        result = result.replace('y', 'Y')
    of confirmNo:
        result = result.replace('n', 'N')
    of confirmQuestionable:
        discard

proc readInput(): Confirmation =
    let input: string = stdin.readLine().strip().toLower()
    case input:
    of "y": confirmYes
    of "n": confirmNo
    else: confirmQuestionable

proc printQuestion(question: string, default: Confirmation) =
    ## Prints the question with the [y/n] prompt
    stdout.write(question & " " & default.getYesNoPrompt() & " ")
    stdout.flushFile()



proc consentOrDie*(question, consentResponse: string, dissentResponse: string = "Quitting...") =
    ## Give consent or terminate process
    printQuestion(question, confirmNo)
    case readInput()
    of confirmYes:
        echo consentResponse
    of confirmNo, confirmQuestionable:
        echo dissentResponse
        exit(QuitFailure)

proc dissentOrContinue*(question, consentResponse: string, dissentResponse: string = "Quitting...") =
    ## Revoke consent or continue with execution
    printQuestion(question, confirmYes)
    case readInput()
    of confirmYes, confirmQuestionable:
        echo consentResponse
    of confirmNo:
        echo dissentResponse
        exit(QuitFailure)

