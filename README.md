# HTML-File-Analyzer

<p align="justify">
Consider an input file in HTML format. After running the program, information about the following will be displayed:
</p>

* tags inside *body*. <br>
* tags inside *div*. <br>
* a list of tags inside *head* *style* and a list of all attributes that appear immediately after the tag (for example, *button type="submit" value="Submit"* -> ["type", "value"]). <br>
* for tags inside *style*, the tag will be specified, followed by a list of all attributes. <br>
* divs will be numbered in the order they appear. <br>
* for style and div tags, a list of the form [*tag* -> [attribute list]] and [*div* -> [tag] -> [attribute list]] will be created. <br>


### Used Variables

<p align="justify">
To store the details of each tag (name and attributes), I used two structures, one for tags in <em>body</em>, one for tags in <em>style</em>. Each tag was added to a specific vector.
</p>


### States. Expressions. Flow.

<p align="justify">
Initially, I wait for <em> body </em> or <em>head</em> to appear on the tape.
If <em>head</em> is encountered, I switch to IN_HEAD state where I wait for <em>style</em> tag. If the tag exists, I switch to IN_STYLE state where I search for tags specific to <em>style</em>. When one is found, I switch to IN_STYLE_TAG state where I add the tag and its attributes to the specific vector of <em>style</em> tags.
</p>

There are 3 important states:

:black_medium_small_square: IN_BODY, from which I go to: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* VOID_IN_BODY - if a void element is encountered on the tape <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* DIV_IN_BODY - if <em>div</em> is encountered on the tape<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* TAG_IN_BODY - if any other tag is encountered on the tape<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- regardless of the state I transition to from here, I store the tag found<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- if that tag is <em>div</em>, I also store its attributes<br>

:black_medium_small_square: TAG_IN_BODY, from which I go to: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* VOID_IN_TAG_BODY - if a void element is encountered on the tape <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* TAG_IN_TAG - if any other tag is encountered on the tape<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* VOID_IN_TAG_IN_TAG - if a void element is found inside another tag<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- have separate states for void elements because they are speciald<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- in TAG_IN_TAG, I stay until the value of the variable (where I store how many tags have been opened) is 0, as previously specified<br>

:black_medium_small_square: DIV_IN_BODY, from which I go to: <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* VOID_IN_DIV - if a void element is encountered on the tape <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* TAG_IN_DIV - if any other tag is encountered on the tape<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* VOID_IN_TAG_IN_DIV - if a void element is found in a tag inside div<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* TAG_IN_TAG_IN_DIV - if another tag is found in a tag inside div<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* VOID_IN_TAG_IN_TAG_IN_DIV - if a void element is found inside another tag inside div<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- the difference between these states and those specific to TAG_IN_BODY is that here I need to store both the tags found and their attributes<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- in TAG_IN_TAG_IN_DIV, I stay until the value of the variable (where I store how many tags have been opened) is 0, meaning that all tags inside a tag in div have been closed<br>
