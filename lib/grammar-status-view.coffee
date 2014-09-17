# View to show the grammar name in the status bar.
class GrammarStatusView extends HTMLElement
  initialize: (@statusBar) ->
    @classList.add('grammar-status', 'inline-block')
    @grammarLink = document.createElement('a')
    @grammarLink.classList.add('inline-block')
    @grammarLink.href = '#'
    @appendChild(@grammarLink)
    @handleEvents()

  attach: ->
    if atom.config.get 'grammar-selector.showOnRightSideOfStatusBar'
      @statusBar.prependRight(this)
    else
      @statusBar.appendLeft(this)

  handleEvents: ->
    @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
      @subscribeToActiveTextEditor()

    @configSubscription = atom.config.observe 'grammar-selector.showOnRightSideOfStatusBar', =>
      @attach()

    clickHandler = ->
      atom.workspaceView.trigger('grammar-selector:show')
      false
    @addEventListener('click', clickHandler)
    @clickSubscription = dispose: => @removeEventListener('click', clickHandler)

    @subscribeToActiveTextEditor()

  destroy: ->
    @activeItemSubscription.dispose()
    @grammarSubscription.dispose()
    @clickSubscription.dispose()
    @configSubscription.off()
    @remove()

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
      if grammar is atom.syntax.nullGrammar
        grammarName = 'Plain Text'
      else
        grammarName = grammar.name ? grammar.scopeName
      @grammarLink.textContent = grammarName
      @grammarLink.dataset.grammar = grammarName
      @style.display = ''
    else
      @style.display = 'none'

module.exports = document.registerElement('grammar-selector-status', prototype: GrammarStatusView.prototype, extends: 'div')
