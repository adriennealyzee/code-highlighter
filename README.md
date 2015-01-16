# Text Highlighter for the Atom Text Editor

![decoration-example](https://cloud.githubusercontent.com/assets/69169/3518389/d9a8344e-06ff-11e4-9283-c32c9d99e0c1.gif)

Uses decoration API.

## What is the Decoration API?

It's common when writing packages to annotate, or decorate lines, gutter line numbers, and highlight ranges of text. The decoration API allows you to add CSS classes and styling to these line, gutter line numbers, and regions of text.

Several packages use decorations: [git-diff] (for gutter diff indicators), [bookmarks] (for gutter book mark indicators), and [find-and-replace] (for boxes around found search terms). Decorations are even used in the core editor: selections (the colored selection regions are decorations), and the highlight in the gutter indicating which line the cursor is on.
