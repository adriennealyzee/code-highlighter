# For now, let's store the comments at the bottom of the page as an array. Each line is an element in the array.
# Each element, is a serialized JSON object.
# It's an array, so that we can add/remove a single entry at a time, without having to rewrite the entire choreography section.
#
# How do we link a marker on the page, to it's matching entry in the choreography array? When we read the choreography and apply its styles, we can add an ID attribute to each element.
# The ID attribute won't get serialized to the eventual json, so we don't have to worry about conflicting ID numbers in different editors/buffers.
# The IDs effectively only apply to the code objects currently visible, not to their seriliazed representations.
#
# Also remember that we need to subscribe to change events on the markers, so we keep them all in check! Possible performance issues here, if encountered we will need to add batch-rewrites.

# Let's say you create a highlight. This is what happens:
#  - get the choreography
#    - which is created if it didn't already exist
#  - create the actual marker
#  - add the onChange callback to update the choreography line
#  - insert the line with the serialized marker text into the choreography comment




# a function which inserts the given text to a buffer at the specified line number
insertText = (buffer, multiLineText) ->
  buffer.

# a function which inserts the given text to the end of a buffer (uses function above)



module.exports = exports
