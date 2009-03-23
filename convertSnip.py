#!/usr/bin/python
# Converts command-based snippet to new file-based snippet syntax
# NOTE: This is only meant to help, it is not perfect! Check the file 
# afterwards to make sure it's correct.

import sys
import re
import os

def Usage():
    print """\
Usage: convertSnip.py -h or --help          Print this help and exit
   or: convertSnip.py inputfile             Print .snippets file
   or: convertSnip.py inputfile outputfile  Output to file"""

def FindSnippet(line):
    """\
    Try to find a snippet in the given line. If it is found, return the 
    converted snippet; otherwise, return -1.\
    """
    snippet = re.search("exe ['\"](GlobalSnip|Snipp)(!)? (\S+) (.*)['\"]", line)
    if not snippet: return -1
    trigger = snippet.group(3)
    text = "\t" + snippet.group(4)

    if snippet.group(2): # Process multi-snippet
        endSnip = re.search('\s*\\\\"(.*?)\\\\"\s*(.*)', text)

        if not endSnip:
            endSnip = re.search('\s*"(.*?)"\s*(.*)', text)
            if not endSnip: return -1

        trigger += ' ' + endSnip.group(1) # Add name to snippet declaration
        text = "\t" + endSnip.group(2)

    return trigger + "\n" + text

newLines = []

def ProcessLine(line):
    """\
    Search the line for a snippet or comment, and append it to newLines[]
    if it is found.\
    """

    snippet = FindSnippet(line)
    if snippet == -1:
        comment = re.match('^"(.*)', line)
        if comment: newLines.append('#' + comment.group(1))
    else:
        newLines.append('snippet ' + snippet)
    return snippet

def Output(lines, file = None):
    outputLines = ''
    for snippet in lines:
        for line in snippet.split("\\n"):
            line = re.sub('\\\\t', "\t", line)
            line = re.sub('\\\\\\\\', '\\\\', line)
            if not re.match('^(\#|snippet)', line):
                line = "\t" + line
            outputLines += line + "\n"
    if file:
        try:
            output = open(file, 'w')
        except IOError, error:
            raise SystemExit('convertSnip.py: %s' % error)
        output.write(outputLines)
    else:
        print outputLines,

def main(argv = None):
    if argv is None: argv = sys.argv[1:]
    if not argv or '-h' in argv or '--help' in argv:
        Usage()
        return 1

    try:
        input = open(argv[0], 'r')
    except IOError, error:
        raise SystemExit('convertSnip.py: %s' % error)

    snippet = -1
    for line in input.readlines():
        if snippet == -1:
            snippet = ProcessLine(line)
        else:
            concat = re.search("^\s+(\\\\\s*)?(\.\s*)?['\"](.*)['\"]", line)
            if concat:
                newLines[-1] += "\\n" + concat.group(3) # Add concatenated lines
            else:
                snippet = ProcessLine(line)

    if len(argv) == 1: Output(newLines)
    else: Output(newLines, argv[1])

if __name__ == '__main__':
    sys.exit(main())
