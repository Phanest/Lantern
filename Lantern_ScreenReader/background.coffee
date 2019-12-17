###
Helpers
###

jsonld = require('../node_modules/jsonld')
jsonldRdfaParser = require('../node_modules/jsonld-rdfa-parser')

class Section
  constructor: (element, content='C:/Users/Kanan-PC/Desktop/Lantern/Lantern_Examples/Lantern.owl/contains') ->
    @id = element['@id']
    @name = element['C:/Users/Kanan-PC/Desktop/Lantern/Lantern_Examples/Lantern.owl/name'][0]['@value']
    @addChildrenIds(element, content)

  addChildrenIds: (element, content) ->
    @children = []
    ids = element[content]
    if not ids?
      return
    if typeof(ids) == 'object' #if multiple children
      for id in ids #todo [udnefined, undefined] at end
        @children.push(id['@id'])
    else
      @children.push(ids['@id'])

  addChildren: (elements) ->
    len = @children.length
    for i in [0...len]
      id = @children[i]
      @children[i] = elements[id][0]
      elements[id][0].parents = @
      elements[id][1] += 1

  onAction: () ->
    return @children


class aText extends Section
  constructor: (element) ->
    super(element, 'C:/Users/Kanan-PC/Desktop/Lantern/Lantern_Examples/Lantern.owl/alternatives')
    @content = element['C:/Users/Kanan-PC/Desktop/Lantern/Lantern_Examples/Lantern.owl/content']?[0]['@value']

  onAction: () ->
    if @children.length == 0
      return @children
    else if @content?
#alert @content #todo read aloud
      console.log @content

class Media extends Section
  constructor: (element) ->
    super(element)
    @source = element['C:/Users/Kanan-PC/Desktop/Lantern/Lantern_Examples/Lantern.owl/source']?[0]['@value']

  onAction: () ->
    if @source?
      console.log @source #todo play source

class Form extends Section
  constructor: (element) ->
    super(element)
    @source = element['C:/Users/Kanan-PC/Desktop/Lantern/Lantern_Examples/Lantern.owl/source']?[0]['@value']

  onAction: () ->
    if @source?
      console.log @source #todo place cursor on button


class Button extends Section
  constructor: (element) ->
    super(element)
    @source = element['C:/Users/Kanan-PC/Desktop/Lantern/Lantern_Examples/Lantern.owl/source']?[0]['@value']

  onAction: () ->
    if @source?
      console.log @source #todo go to link

class Comments
  constructor: (element) ->

class notification
  constructor: (element) ->

class tree
  constructor: (elements) ->
    @children = []
    for key of elements
      element = elements[key]
      if element[1] == 0
        element[0].parent = @
        @children.push(element[0])

#each class has id
addElement = (element) ->
  Type = element["@type"][0]
  filter = /[A-Za-z]*$/
  Type = filter.exec(Type)[0]
  obj = null

  switch Type
    when 'section' then new Section(element)
    when 'text' then new aText(element)
    when 'media' then new Media(element)
    when 'form' then new Form(element)
    when 'button' then new Button(element)
    when 'comment' then new Comments(element)
    when 'notification' then new notification(element)
    else null

###
  Listens for events in the browser, if it's triggered it runs and then unloads itself
###

chrome.runtime.onInstalled.addListener ->
  #storage lets multiple extension components access this parameter
  chrome.storage.sync.set {s: '#3aa757'}, ->
    console.log "green"

#loaded when needed and then removed
chrome.declarativeContent.onPageChanged.removeRules undefined, ->
  chrome.declarativeContent.onPageChanged.addRules [
    conditions: [new chrome.declarativeContent.PageStateMatcher
      pageUrl: {hostEquals: 'developer.chrome.com'}
    ],
    actions: [new chrome.declarativeContent.ShowPageAction]
  ]

#listen for DOM elements
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  content = request.elements
  console.log content
  console.log 'I am here'

  jsonld.registerRDFParser 'text/html', jsonldRdfaParser
  jsonld.fromRDF content, {format: 'text/html'}, (err, data) ->
    content = data
    console.log data
    elements = {}
    mark = 0
    for element in content
      #Skip declarations
      if mark == 0
        mark = 1
        continue

      node = addElement(element)
      if not node?
        continue

      a = [node, 0]
      elements[node.id] = a

    #elements = {id: [node, 0]...}
    for key of elements
      element = elements[key][0]
      element.addChildren(elements)

    root = new tree(elements)
    elements =
      elements: root.children,
      index: 0,
      read: 0,
      notifications: []

    console.log 'background.coffee'
    console.log elements

    chrome.storage.local.set {test: elements}

#if not elements?
#  elements = null
#chrome.storage.local.get ['test'], (result) ->
#  elements = result.test

#TODO use onPageChange
#If no tree, or new page, or page change
  #parse tree (content script)
  #read elements name (function)

#On refresh rate
  #parse page for notifications
  #add list to notifications, change index to 0
  #if change read elements name using index

#Notifications OPTIONAL
#Keep list of elements, {elements: [], index = 0, notifications: []}
#when issuing command, if index >= len(notifications) element[index] else notifications[index]

#todo OPTIONAL, listen for changes

#Commands must be issued with Ctrl
chrome.commands.onCommand.addListener (command) ->
  alert command

  chrome.storage.local.get ['test'], (result) ->
    elements = result.test
    if not elements? #The tree is still not generated
      alert 'no elements'
      return

    console.log elements['elements']
    ar = elements['elements'][0].children
    for el in ar
      chrome.tts.speak(el.name, {'enqueue': true})
    #if 1, 2, 3, 4 (is for more)
      #if number is functional
        #if element has action
          #Element.onAction (if it's a paragraph, onAction may include speaking, if it's a button clicking and if form, setting the cursor and notifying the user)
          #if new list is returned
          #add elements to UI, refresh index
    #if 5
      #if functional
        #index + 4
        #add elements to UI
    #if esc
      #if element in elements has parent has parent
        #list is element.parent.parent.children()
        #add elements to UI, refresh index, destroy notifications
    #repeat does nothing but still reads the elements
    #read list using index (function)