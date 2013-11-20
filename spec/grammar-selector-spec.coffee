{_, $, RootView, View} = require 'atom'

class StatusBarMock extends View
  @content: ->
    @div class: 'status-bar tool-panel panel-bottom', =>
      @div outlet: 'leftPanel', class: 'status-bar-left'

  attach: ->
    atom.rootView.vertical.append(this)

  appendLeft: (item) ->
    @leftPanel.append(item)

describe "GrammarSelector", ->
  [editor, textGrammar, jsGrammar] =  []

  beforeEach ->
    atom.rootView = new RootView
    atom.packages.activatePackage('grammar-selector')
    atom.packages.activatePackage('language-text', sync: true)
    atom.packages.activatePackage('language-javascript', sync: true)
    atom.rootView.openSync('sample.js')
    editor = atom.rootView.getActiveView()
    textGrammar = _.find atom.syntax.grammars, (grammar) -> grammar.name is 'Plain Text'
    expect(textGrammar).toBeTruthy()
    jsGrammar = _.find atom.syntax.grammars, (grammar) -> grammar.name is 'JavaScript'
    expect(jsGrammar).toBeTruthy()
    expect(editor.getGrammar()).toBe jsGrammar

  describe "when grammar-selector:show is triggered", ->
    it "displays a list of all the available grammars", ->
      editor.trigger 'grammar-selector:show'
      grammarView = atom.rootView.find('.grammar-selector').view()
      expect(grammarView).toExist()
      {grammars} = atom.syntax
      expect(grammarView.list.children('li').length).toBe grammars.length
      expect(grammarView.list.children('li:first').text()).toBe 'Auto Detect'
      for li in grammarView.list.children('li')
        expect($(li).text()).not.toBe atom.syntax.nullGrammar.name

  describe "when a grammar is selected", ->
    it "sets the new grammar on the editor", ->
      editor.trigger 'grammar-selector:show'
      grammarView = atom.rootView.find('.grammar-selector').view()
      grammarView.confirmed(textGrammar)
      expect(editor.getGrammar()).toBe textGrammar

  describe "when auto-detect is selected", ->
    it "restores the auto-detected grammar on the editor", ->
      editor.trigger 'grammar-selector:show'
      grammarView = atom.rootView.find('.grammar-selector').view()
      grammarView.confirmed(textGrammar)
      expect(editor.getGrammar()).toBe textGrammar

      editor.trigger 'grammar-selector:show'
      grammarView = atom.rootView.find('.grammar-selector').view()
      grammarView.confirmed(grammarView.array[0])
      expect(editor.getGrammar()).toBe jsGrammar

  describe "when the editor's current grammar is the null grammar", ->
    it "displays Auto Detect as the selected grammar", ->
      editor.activeEditSession.setGrammar(atom.syntax.nullGrammar)
      editor.trigger 'grammar-selector:show'
      grammarView = atom.rootView.find('.grammar-selector').view()
      expect(grammarView.list.children('li.active').text()).toBe 'Auto Detect'

  describe "adding grammar selector to the status-bar", ->
    beforeEach ->
      atom.rootView.statusBar = new StatusBarMock()
      atom.rootView.statusBar.attach()
      atom.packages.emit('activated')

    it 'is in the status-bar', ->
      expect(atom.rootView.find('.status-bar .grammar-name')).toExist()

  describe "grammar label", ->
    statusBar = null

    beforeEach ->
      atom.rootView.statusBar = statusBar = new StatusBarMock()
      atom.rootView.statusBar.attach()
      atom.packages.emit('activated')

    afterEach ->
      atom.rootView.statusBar.remove()
      atom.rootView.statusBar = null

    it "displays the name of the current grammar", ->
      expect(statusBar.find('.grammar-name').text()).toBe 'JavaScript'

    it "displays Plain Text when the current grammar is the null grammar", ->
      atom.rootView.attachToDom()
      editor.activeEditSession.setGrammar(atom.syntax.nullGrammar)
      expect(statusBar.find('.grammar-name')).toBeVisible()
      expect(statusBar.find('.grammar-name').text()).toBe 'Plain Text'
      editor.reloadGrammar()
      expect(statusBar.find('.grammar-name')).toBeVisible()
      expect(statusBar.find('.grammar-name').text()).toBe 'JavaScript'

    it "hides the label when the current grammar is null", ->
      atom.rootView.attachToDom()
      spyOn(editor, 'getGrammar').andReturn null
      editor.activeEditSession.setGrammar(atom.syntax.nullGrammar)

      expect(statusBar.find('.grammar-name')).toBeHidden()

    describe "when the editor's grammar changes", ->
      it "displays the new grammar of the editor", ->
        atom.syntax.setGrammarOverrideForPath(editor.getPath(), 'text.plain')
        editor.reloadGrammar()
        expect(statusBar.find('.grammar-name').text()).toBe 'Plain Text'

    describe "when clicked", ->
      it "toggles the grammar-selector:show event", ->
        eventHandler = jasmine.createSpy('eventHandler')
        editor.on 'grammar-selector:show', eventHandler
        statusBar.find('.grammar-name').click()
        expect(eventHandler).toHaveBeenCalled()
