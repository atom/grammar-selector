{Disposable} = require 'atom'

# View to show the grammar name in the status bar.
class GrammarStatusView extends HTMLElement
  initialize: (@statusBar) ->
    @classList.add('grammar-status', 'inline-block')
    @grammarLink = document.createElement('a')
    @grammarLink.classList.add('inline-block')
    @grammarLink.href = '#'
    @appendChild(@grammarLink)
    @handleEvents()
    this

  attach: ->
    @statusBarTile?.destroy()
    @statusBarTile =
      if atom.config.get 'grammar-selector.showOnRightSideOfStatusBar'
        @statusBar.addRightTile(item: this, priority: 10)
      else
        @statusBar.addLeftTile(item: this, priority: 10)

  handleEvents: ->
    @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
      @subscribeToActiveTextEditor()

    @configSubscription = atom.config.observe 'grammar-selector.showOnRightSideOfStatusBar', =>
      @attach()

    clickHandler = -> atom.commands.dispatch(this, 'grammar-selector:show')
    @addEventListener('click', clickHandler)
    @clickSubscription = new Disposable => @removeEventListener('click', clickHandler)

    @subscribeToActiveTextEditor()

  destroy: ->
    @activeItemSubscription?.dispose()
    @grammarSubscription?.dispose()
    @clickSubscription?.dispose()
    @configSubscription?.dispose()
    @statusBarTile.destroy()

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  subscribeToActiveTextEditor: ->
    @grammarSubscription?.dispose()
    @grammarSubscription = @getActiveTextEditor()?.onDidChangeGrammar =>
      @updateGrammarText()
    @updateGrammarText()

  updateGrammarText: ->
    grammar = @getActiveTextEditor()?.getGrammar?()
    if grammar?
      if grammar is atom.grammars.nullGrammar
        grammarName = 'Plain Text'
      else
        grammarName = grammar.name ? grammar.scopeName
      @grammarLink.textContent = grammarName
      @grammarLink.dataset.grammar = grammarName
      @style.display = ''
    else
      @style.display = 'none'

module.exports = document.registerElement('grammar-selector-status', prototype: GrammarStatusView.prototype, extends: 'div')
