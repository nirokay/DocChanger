import std/[os, parsexml]
import constants

let xmlFile: string = tempWorkingUnzipped & "word/document.xml"

var xml = parseXml