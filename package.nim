# import pkginfo

# let pkg = pkg("docchanger")

const
    projectName*: string = "docchanger" # pkg.getName()
    projectDescription*: string = "Replaces specific xml text in .docx files." # pkg.getDescription()
    projectVersion*: string = "v0.1.0" # "v" & pkg.version()
    projectAuthors*: seq[string] = @["nirokay"] # @[pkg.getAuthor()]
    projectLicence*: string = "GPL-3.0-only" # pkg.getLicense()
    projectSource*: string = "https://github.com/nirokay/DocChanger/"
