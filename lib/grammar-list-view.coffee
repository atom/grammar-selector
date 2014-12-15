{SelectListView} = require 'atom-space-pen-views'

# View to display a list of grammars to apply to the current editor.
module.exports =
class GrammarListView extends SelectListView
  initialize: ->
    super

    @addClass('grammar-selector')
    @list.addClass('mark-active')
    @autoDetect = name: 'Auto Detect'

  getFilterKey: ->
    'name'

  destroy: ->
    @cancel()

  viewForItem: (grammar) ->
    element = document.createElement('li')
    element.classList.add('active') if grammar is @currentGrammar
    grammarName = grammar.name ? grammar.scopeName
    element.textContent = grammarName
    element.dataset.grammar = grammarName
    element

  cancelled: ->
    @panel?.destroy()
    @panel = null
    @editor = null
    @currentGrammar = null

  confirmed: (grammar) ->
    if grammar is @autoDetect
      atom.grammars.clearGrammarOverrideForPath(@editor.getPath())
      @editor.reloadGrammar()
    else
      atom.grammars.setGrammarOverrideForPath(@editor.getPath(), grammar.scopeName)
      @editor.setGrammar(grammar)
    @cancel()

  attach: ->
    @storeFocusedElement()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @focusFilterEditor()

  toggle: ->
    if @panel
      @cancel()
    else if @editor = atom.workspace.getActiveTextEditor()
      @currentGrammar = @editor.getGrammar()
      @currentGrammar = @autoDetect if @currentGrammar is atom.grammars.nullGrammar
      @setItems(@getGrammars())
      @attach()

  getGrammars: ->
    grammars = atom.grammars.getGrammars().filter (grammar) ->
      grammar isnt atom.grammars.nullGrammar

    grammars.sort (grammarA, grammarB) ->
      if grammarA.scopeName is 'text.plain'
        -1
      else if grammarB.scopeName is 'text.plain'
        1
      else
        grammarA.name?.localeCompare?(grammarB.name) ? grammarA.scopeName?.localeCompare?(grammarB.name) ? 1

    grammars.unshift(@autoDetect)
    grammars
