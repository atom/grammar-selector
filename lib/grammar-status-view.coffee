{View} = require 'atom'

# View to show the grammar name in the status bar.
module.exports =
class GrammarStatusView extends View
  @content: ->
    @a href: '#', class: 'grammar-name inline-block'

  initialize: (@statusBar) ->
    @subscribe @statusBar, 'active-buffer-changed', =>
      @updateGrammarText()

    @subscribe atom.workspaceView, 'editor:grammar-changed', =>
      @updateGrammarText()

    @subscribe this, 'click', ->
      atom.workspaceView.trigger('grammar-selector:show')
      false

  attach: ->
    @statusBar.appendLeft(this)

  afterAttach: ->
    @updateGrammarText()

  updateGrammarText: ->
    grammar = atom.workspace.getActiveEditor()?.getGrammar?()
    if grammar?
      if grammar is atom.syntax.nullGrammar
        grammarName = 'Plain Text'
      else
        grammarName = grammar.name
      @text(grammarName).show()
    else
      @hide()
