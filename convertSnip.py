#!/usr/bin/python
"""
File: convertSnips.py
Author: Michael Sanders
Description: Converts command-based snippets to new file-based snippet syntax.
NOTE: This is only meant to help, it is not perfect! Check the file afterwards
to make sure it's correct.
"""

import sys, re

def usage():
    """Print usage message and exit."""
    print """\
Usage: convertSnips.py -h or --help              Print this help and exit
   or: convertSnips.py [inputfile]               Print .snippets file
   or: convertSnips.py [inputfile] [outputfile]  Output to file"""

def find_snippet(line):
    """
    Try to find a snippet in the given line. If it is found, return the
    converted snippet; otherwise, return -1.
    """
    snippet = re.search("exe ['\"](GlobalSnip|Snipp)(!)? (\S+) (.*)['\"]", line)
    if not snippet:
        return -1
    trigger = snippet.group(3)
    text = "\t" + snippet.group(4)

    if snippet.group(2): # Process multi-snippet
        end_snip = re.search(r'\s*\\"(.*?)\\"\s*(.*)', text)

        if not end_snip:
            end_snip = re.search('\s*"(.*?)"\s*(.*)', text)
            if not end_snip:
                return -1

        trigger += ' ' + end_snip.group(1) # Add name to snippet declaration
        text = "\t" + end_snip.group(2)

    return trigger + "\n" + text

def process_line(line, new_lines):
    """
    Search the line for a snippet or comment, and append it to new_lines[]
    if it is found.
    """

    snippet = find_snippet(line)
    if snippet == -1:
        comment = re.match('^"(.*)', line)
        if comment:
            new_lines.append('#' + comment.group(1))
    else:
        new_lines.append('snippet ' + snippet)
    return snippet, new_lines

def output_lines(lines, outputfile = None):
    """Prints or outputs to file the converted snippets."""
    file_lines = ''
    for snippet in lines:
        for line in snippet.split("\\n"):
            line = re.sub(r'\\t', '\t', line)
            line = re.sub(r'\\\\', r'\\', line)
            if not re.match('^(\#|snippet|$)', line):
                line = "\t" + line
            file_lines += line + "\n"
    if outputfile:
        try:
            output = open(outputfile, 'w')
        except IOError, error:
            raise SystemExit('convertSnips.py: %s' % error)
        output.write(file_lines)
    else:
        print file_lines,

def main(argv = None):
    if argv is None:
        argv = sys.argv[1:]
    if not argv or '-h' in argv or '--help' in argv:
        usage()
        return 1

    try:
        inputfile = open(argv[0], 'r')
    except IOError, error:
        raise SystemExit('convertSnips.py: %s' % error)

    snippet = -1
    new_lines = []
    for line in inputfile.readlines():
        if snippet == -1:
            snippet, new_lines = process_line(line, new_lines)
        else:
            concat = re.search(r"^\s+(\\\s*)?(\.\s*)?['\"](.*)['\"]", line)
            if concat:
                new_lines[-1] += "\n" + concat.group(3) # Add concatenated lines
            else:
                snippet, new_lines = process_line(line, new_lines)

    if len(argv) == 1:
        output_lines(new_lines)
    else:
        output_lines(new_lines, argv[1])

if __name__ == '__main__':
    sys.exit(main())
