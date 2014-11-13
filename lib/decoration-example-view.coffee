{View, Range} = require 'atom'

module.exports =
class DecorationExampleView extends View
  @content: ->
    @div class: 'decoration-example tool-panel panel-bottom padded', =>
      @div class: 'btn-toolbar', =>
        #@div class: 'btn-group', =>
          #@button outlet: 'gutterToggle', class: 'btn', 'Toggle Gutter Decoration'
          #@button outlet: 'gutterColorCycle', class: 'btn', 'Cycle Gutter Color'

        #@div class: 'btn-group', =>
          #@button outlet: 'lineToggle', class: 'btn', 'Toggle Lines Decoration'
          #@button outlet: 'lineColorCycle', class: 'btn', 'Cycle Lines Color'

        @div class: 'btn-group', =>
          @button outlet: 'highlightToggle', class: 'btn', 'Add highlight'
          @button outlet: 'removeHighlight', class: 'btn', 'Remove highlight'
          #@button outlet: 'highlightColorCycle', class: 'btn', 'Cycle Highlight Color'

  colors: ['green', 'blue', 'red']
  randomizeColors: true

  initialize: (serializeState) ->
    @decorationsByEditorId = {}
    @toggleButtons =
      #line: @lineToggle
      #gutter: @gutterToggle
      highlight: @highlightToggle

    #@lineToggle.on 'click', => @toggleDecorationForCurrentSelection('line')
    #@gutterToggle.on 'click', => @toggleDecorationForCurrentSelection('gutter')
    @highlightToggle.on 'click', => @createDecorationForCurrentSelection('highlight')
    @removeHighlight.on 'click', => @destroyDecorationsAtCursor()

    #@lineColorCycle.on 'click', => @cycleDecorationColor('line')
    #@gutterColorCycle.on 'click', => @cycleDecorationColor('gutter')
    #@highlightColorCycle.on 'click', => @cycleDecorationColor('highlight')

    atom.workspaceView.on 'pane-container:active-pane-item-changed', => @updateToggleButtonStates()

  ## Decoration API methods

  destroyDecorationsAtCursor: ->
    markersArr = @getMarkersAtCursor()
    for marker in markersArr
      # destroy marker if the marker is a relevant market (i.e. highlighted by user)
      @destroyMarker(marker) if marker.getProperties()['addy-highlight']

  createDecorationFromCurrentSelection: (editor, type) ->

    # cereal = '[{"color":"red","range":[[0,0],[58,0]]}, {"color": "blue", "range":[[61,3],[66,3]]}]'
    # @deserialize_markers(JSON.parse(cereal))

    color = @getRandomColor()

    # Get the user's selection from the editor
    range = editor.getSelectedBufferRange()

    @createHighlight(color, range)

  createHighlight: (color, range) ->
    editor = @getEditor()
    console.log color, range
    # create a marker that never invalidates that folows the user's selection range
    marker = editor.markBufferRange(range, invalidate: 'never')
    marker.bufferMarker.setProperties('addy-highlight': color)

    # create a decoration that follows the marker. A Decoration object is returned which can be updated
    decoration = editor.decorateMarker(marker, type: 'highlight', class: "highlight-#{color}")

  updateDecoration: (decoration, newDecorationParams) ->
    # This allows you to change the class on the decoration
    decoration.update(newDecorationParams)

  destroyMarker: (marker) ->
    # Destroy the decoration's marker because we will no longer need it.
    # This will destroy the decoration as well. Destroying the marker is the
    # recommended way to destory the decorations.
    marker.destroy()

  getMarkersAtCursor: () ->
    editor = @getEditor()
    buffer = editor.buffer
    point = editor.getCursor().getBufferPosition()
    markers = buffer.findMarkers(containsPoint: point)


  ## Button handling methods

  createDecorationForCurrentSelection: ->
    @createDecorationFromCurrentSelection(@getEditor(), 'highlight')

  toggleDecorationForCurrentSelection: (type) ->
    return unless editor = @getEditor()

    decoration = @getCachedDecoration(editor, type)
    if decoration?
      @destroyDecorationMarker(decoration)
      @setCachedDecoration(editor, type, null)
    else
      decoration = @createDecorationFromCurrentSelection(editor, type)
      @setCachedDecoration(editor, type, decoration)

    @updateToggleButtonStates()
    atom.workspaceView.focus()
    decoration

  updateToggleButtonStates: ->
    if editor = @getEditor()
      decorations = @decorationsByEditorId[editor.id] ? {}
      for type, button of @toggleButtons
        if decorations[type]?
          button.addClass('selected')
        else
          button.removeClass('selected')
    else
      for type, button of @toggleButtons
        button.removeClass('selected')

  cycleDecorationColor: (type) ->
    return unless editor = @getEditor()

    decoration = @getCachedDecoration(editor, type)
    decoration ?= @toggleDecorationForCurrentSelection(type)

    klass = decoration.getParams().class
    currentColor = klass.replace("#{type}-", '')
    newColor = @colors[(@colors.indexOf(currentColor) + 1) % @colors.length]
    klass = "#{type}-#{newColor}"

    @updateDecoration(decoration, {type, class: klass})

  ## Utility methods

  getEditor: ->
    atom.workspace.getActiveEditor()

  getCachedDecoration: (editor, type) ->
    (@decorationsByEditorId[editor.id] ? {})[type]

  setCachedDecoration: (editor, type, decoration) ->
    @decorationsByEditorId[editor.id] ?= {}
    @decorationsByEditorId[editor.id][type] = decoration

  getRandomColor: ->
    if @randomizeColors
      @colors[Math.round(Math.random() * 2)]
    else
      @colors[0]

  attach: ->
    atom.workspaceView.prependToBottom(this)

  # Tear down any state and detach
  destroy: ->
    @detach()

  get_all_markers: ->
    editor = atom.workspace.getActiveEditor()
    buffer = editor.buffer
    markers = buffer.getMarkers()

  getAddyMarkers: ->
    markers = atom.workspace.getActiveEditor()
    addy_markers = editor.buffer.getMarkers().filter (x) ->
      x.getProperties()['addy-highlight']

  # takes an array of addy_markers
  # and returns an array of objects
  # each object consists of following:
  # 1) string representing color
  # 2) range object of marker
  serialized_markers = (addy_markers) ->
    addy_markers.map (marker) ->
      return { color: marker.getProperties()['addy-highlight'], range: marker.range.serialize() }

  # takes in comments at the bottom
  # array of colors and ranges (serialized_markers)
  # adds to buffer


  # put this at the bottom for comments


  # cereal = serialized_markers(addy_markers)
  # cereal_comments = JSON.stringify(cereal)
  # # put cereal_comments into end of file
  # cereal_objects = JSON.parse(cereal_comments)


  # takes in serialized_markers
  deserialize_markers: (serialized_markers) ->
    self = this
    serialized_markers.map (serialized_highlight) ->
      console.log "RANGEX", new Range(serialized_highlight.range)
      self.createHighlight(serialized_highlight.color, Range.deserialize(serialized_highlight.range))




### !@#$%>haightlighter infos
highlight all my favorite words ['cheese', 'bread']
###
