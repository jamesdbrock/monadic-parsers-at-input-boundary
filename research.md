When you get a bytestream from over the I/O boundary, you want to parse it.
In in the year 2022, most people:
1. Write an ad-hoc parser based on splitting.
2. Use regular expressions.
3. If an input bytestream has any tree structure, then they declare that the
input bytestream must be JSON.

This why the whole world is JSONified. Because good JSON parsers exist for all
languages, and any tree-structured data can be expressed as JSON. But this
sucks. 

The entire Perl programming language was built around regular expressions.

https://en.wikipedia.org/wiki/Comparison_of_regular_expression_engines

