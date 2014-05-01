{View} = require 'atom'

# View to show the grammar name in the status bar.
module.exports =
class GrammarStatusView extends View
  @content: ->
    @a href: '#', class: 'inline-block'

  initialize: (@statusBar) ->
    @subscribe @statusBar, 'active-buffer-changed', =>
      @updateGrammarText()

    @subscribe atom.workspaceView, 'editor:grammar-changed', =>
      @updateGrammarText()

    atom.config.observe 'grammar-selector.right', =>
      @attach()

    @subscribe this, 'click', ->
      atom.workspaceView.trigger('grammar-selector:show')
      false

  attach: ->
    if atom.config.get 'grammar-selector.right'
      @statusBar.prependRight(this)
    else
      @statusBar.appendLeft(this)

  afterAttach: ->
    @updateGrammarText()

  updateGrammarText: ->
    grammar = atom.workspace.getActiveEditor()?.getGrammar?()
    if grammar?
      if grammar is atom.syntax.nullGrammar
        grammarName = 'Plain Text'
      else
        grammarName = grammar.name ? grammar.scopeName
      @text(grammarName).show()
    else
      @hide()
