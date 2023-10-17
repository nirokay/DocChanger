# Topic Doc Changer

A highly specific tool developed for a single, niche purpose.

## Compilation flags

**Usage:**

When compiling, append flags in this pattern: `-d:flag:value`

Example: `nimble build -d:outputDocument:myoutput.docx`

**List of supported compilation flags (along with their types and default values):**

* `sourcedocument`: string = *unspecified-document.docx* ***(!PLACEHOLDER!)***
* `outputDocument`: string = *document.out.docx* (sets the name of the final document)
