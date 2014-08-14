path = require 'path'
{$, WorkspaceView, View} = require 'atom'

class StatusBarMock extends View
  @content: ->
    @div class: 'status-bar tool-panel panel-bottom', =>
      @div outlet: 'leftPanel', class: 'status-bar-left'

  attach: ->
    atom.workspaceView.appendToTop(this)

  appendLeft: (item) ->
    @leftPanel.append(item)

describe "GrammarSelector", ->
  [editor, editorView, textGrammar, jsGrammar] =  []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model
    atom.config.set('grammar-selector.showOnRightSideOfStatusBar', false)

    waitsForPromise ->
      atom.packages.activatePackage('grammar-selector')

    waitsForPromise ->
      atom.packages.activatePackage('language-text')

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.packages.activatePackage(path.join(__dirname, 'fixtures', 'language-with-no-name'))


    waitsForPromise ->
      atom.workspace.open('sample.js')

    runs ->
      editorView = atom.workspaceView.getActiveView()
      {editor} = editorView
      textGrammar = atom.syntax.grammarForScopeName('text.plain')
      expect(textGrammar).toBeTruthy()
      jsGrammar = atom.syntax.grammarForScopeName('source.js')
      expect(jsGrammar).toBeTruthy()
      expect(editor.getGrammar()).toBe jsGrammar

  describe "when grammar-selector:show is triggered", ->
    it "displays a list of all the available grammars", ->
      editorView.trigger 'grammar-selector:show'
      grammarView = atom.workspaceView.find('.grammar-selector').view()
      expect(grammarView).toExist()
      {grammars} = atom.syntax
      expect(grammarView.list.children('li').length).toBe grammars.length
      expect(grammarView.list.children('li:first').text()).toBe 'Auto Detect'
      expect(grammarView.list.children('li:contains(source.a)')).toExist()
      for li in grammarView.list.children('li')
        expect($(li).text()).not.toBe atom.syntax.nullGrammar.name

  describe "when a grammar is selected", ->
    it "sets the new grammar on the editor", ->
      editorView.trigger 'grammar-selector:show'
      grammarView = atom.workspaceView.find('.grammar-selector').view()
      grammarView.confirmed(textGrammar)
      expect(editor.getGrammar()).toBe textGrammar

  describe "when auto-detect is selected", ->
    it "restores the auto-detected grammar on the editor", ->
      editorView.trigger 'grammar-selector:show'
      grammarView = atom.workspaceView.find('.grammar-selector').view()
      grammarView.confirmed(textGrammar)
      expect(editor.getGrammar()).toBe textGrammar

      editorView.trigger 'grammar-selector:show'
      grammarView = atom.workspaceView.find('.grammar-selector').view()
      grammarView.confirmed(grammarView.items[0])
      expect(editor.getGrammar()).toBe jsGrammar

  describe "when the editor's current grammar is the null grammar", ->
    it "displays Auto Detect as the selected grammar", ->
      editor.setGrammar(atom.syntax.nullGrammar)
      editorView.trigger 'grammar-selector:show'
      grammarView = atom.workspaceView.find('.grammar-selector').view()
      expect(grammarView.list.children('li.active').text()).toBe 'Auto Detect'

  describe "when editor is untitled", ->
    it "sets the new grammar on the editor", ->
      waitsForPromise ->
        atom.workspace.open()

      runs ->
        editorView = atom.workspaceView.getActiveView()
        {editor} = editorView

        editorView.trigger 'grammar-selector:show'
        expect(editor.getGrammar()).not.toBe jsGrammar
        grammarView = atom.workspaceView.find('.grammar-selector').view()
        grammarView.confirmed(jsGrammar)
        expect(editor.getGrammar()).toBe jsGrammar

  describe "grammar label", ->
    [grammarStatus] = []

    beforeEach ->
      atom.workspaceView.statusBar = new StatusBarMock()
      atom.workspaceView.statusBar.attach()
      atom.packages.emit('activated')

      grammarStatus = atom.workspaceView.statusBar.leftPanel.children().view()
      expect(grammarStatus).toExist()

    afterEach ->
      atom.workspaceView.statusBar.remove()
      atom.workspaceView.statusBar = null

    it "displays the name of the current grammar", ->
      expect(grammarStatus.text()).toBe 'JavaScript'

    it "displays Plain Text when the current grammar is the null grammar", ->
      atom.workspaceView.attachToDom()
      editor.setGrammar(atom.syntax.nullGrammar)
      expect(grammarStatus).toBeVisible()
      expect(grammarStatus.text()).toBe 'Plain Text'
      editor.reloadGrammar()
      expect(grammarStatus).toBeVisible()
      expect(grammarStatus.text()).toBe 'JavaScript'

    it "hides the label when the current grammar is null", ->
      atom.workspaceView.attachToDom()
      spyOn(editor, 'getGrammar').andReturn null
      editor.setGrammar(atom.syntax.nullGrammar)

      expect(grammarStatus).toBeHidden()

    describe "when the editor's grammar changes", ->
      it "displays the new grammar of the editor", ->
        atom.syntax.setGrammarOverrideForPath(editor.getPath(), 'text.plain')
        editor.reloadGrammar()
        expect(grammarStatus.text()).toBe 'Plain Text'

        atom.syntax.setGrammarOverrideForPath(editor.getPath(), 'source.a')
        editor.reloadGrammar()
        expect(grammarStatus.text()).toBe 'source.a'

    describe "when clicked", ->
      it "toggles the grammar-selector:show event", ->
        eventHandler = jasmine.createSpy('eventHandler')
        atom.workspaceView.on 'grammar-selector:show', eventHandler
        grammarStatus.click()
        expect(eventHandler).toHaveBeenCalled()
