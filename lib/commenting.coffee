_ = require 'underscore-plus'

class Commenting
  constructor: (editor) ->
    @editor = editor

  getCommentStartString: ->

    scopeDescriptor = @editor.scopeDescriptorForBufferPosition([0, 0])
    properties = atom.config.settingsForScopeDescriptor(scopeDescriptor, 'editor.commentStart')[0]

    _.valueForKeyPath(properties, 'editor.commentStart')

  commentate: (line) ->
    return getCommentStartString() + line

module.exports = Commenting
