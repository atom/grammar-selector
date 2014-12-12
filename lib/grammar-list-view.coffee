{SelectListView} = require 'atom'

# View to display a list of grammars to apply to the current editor.
module.exports =
class GrammarListView extends SelectListView
  initialize: (@editor) ->
    super

    @addClass('grammar-selector')
    @list.addClass('mark-active')

    @autoDetect = name: 'Auto Detect'
    @currentGrammar = @editor.getGrammar()
    @currentGrammar = @autoDetect if @currentGrammar is atom.syntax.nullGrammar

    @subscribe this, 'grammar-selector:show', =>
      @cancel()
      false

    @setItems(@getGrammars())

  getFilterKey: ->
    'name'

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

  confirmed: (grammar) ->
    @cancel()
    if grammar is @autoDetect
      atom.syntax.clearGrammarOverrideForPath(@editor.getPath())
      @editor.reloadGrammar()
    else
      atom.syntax.setGrammarOverrideForPath(@editor.getPath(), grammar.scopeName)
      @editor.setGrammar(grammar)

  attach: ->
    @storeFocusedElement()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @focusFilterEditor()

  getGrammars: ->
    grammars = atom.syntax.getGrammars().filter (grammar) ->
      grammar isnt atom.syntax.nullGrammar

    grammars.sort (grammarA, grammarB) ->
      if grammarA.scopeName is 'text.plain'
        -1
      else if grammarB.scopeName is 'text.plain'
        1
      else
        grammarA.name?.localeCompare?(grammarB.name) ? grammarA.scopeName?.localeCompare?(grammarB.name) ? 1

    grammars.unshift(@autoDetect)
    grammars
