###
Helpers
###

jsonld = require('../node_modules/jsonld')
jsonldRdfaParser = require('../node_modules/jsonld-rdfa-parser')

class Section
  constructor: (element, content='contains') ->
    @id = element['@id']
    key = findKey(element, 'name')
    @name = element[key][0]['@value']
    @type = 'section'
    @addChildrenIds(element, content)

  addChildrenIds: (element, content) ->
    @children = []
    content = findKey(element, content)
    ids = element[content]
    if not ids?
      return
    if typeof(ids) == 'object' #if multiple children
      for id in ids
        @children.push(id['@id'])
    else
      @children.push(ids['@id'])

  addChildren: (elements) ->
    len = @children.length
    for i in [0...len]
      id = @children[i]
      elements[id][0].parent = @id
      @children[i] = elements[id][0]
      elements[id][1] += 1

  onAction: () ->
    return @children


class aText extends Section
  constructor: (element) ->
    super(element, 'alternatives')
    key = findKey(element, 'content')
    @content = element[key]?[0]['@value']
    @type = 'text'

  onAction: () ->
    if @children.length > 0
      return @children
    else if @content?
      chrome.tts.speak(@content)
      console.log @content

class Media extends Section
  constructor: (element) ->
    super(element)
    key = findKey(element, 'source')
    @source = element[key]?[0]['@id']
    key = findKey(element, 'type', true)
    @mediaType = element[key]?[0]['@value']
    @type = 'media'

  onAction: () ->
    if @source?
      console.log @source #todo play source

class Form extends Section
  constructor: (element) ->
    super(element)
    key = findKey(element, 'source')
    @source = element[key]?[0]['@value']
    @type = 'form'

  onAction: () ->
    if @source?
      console.log @source #todo place cursor on button


class Button extends Section
  constructor: (element) ->
    super(element)
    key = findKey(element, 'source')
    @source = element[key]?[0]
    if '@id' in Object.keys(@source)
      @source = @source['@id']
      @buttonType = 'link'
    else
      @source = @source['@value']
      @buttonType = 'button'
    @type = 'button'

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

findKey = (dict, key, exclude=false) ->
  for k of dict
    filter = /[A-Za-z]*$/
    match = filter.exec(k)[0]

    if exclude
      if '@' in k
        continue

    if match == key
      return k

readMenu = (menu, index) ->
  len = menu.length
  more = 0
  if len - index > 4
    more = 1
    len = index + 4

  for i in [index...len]
    element = menu[i]
    chrome.tts.speak(element.name, {'enqueue': true})

  if more == 1
    chrome.tts.speak('more', {'enqueue': true})

getParent = (elements) ->
  menu = elements['elements'][0].parent
  nodes = elements['nodes']
  if findKey(nodes, menu)?
    return null
  parent = nodes[menu]?[0].parent

  if not menu?
    return elements['elements']
  else if not parent?
    list = []
    for key of nodes
      node = nodes[key]
      if node[1] == 0
        list.push(node[0])
    return list
  else
    return nodes[parent][0].children

onAction = (element) ->
  type = element.type
  if element.children.length > 0
    return element.children
  else
    switch type
      when 'text' then speak(element.content)
      when 'media' then play(element.source, element.mediaType)
      when 'form' then place(element.source)
      when 'button' then click(element.source)

speak = (content) ->
  if content?
    chrome.tts.speak(content)

play = (source, type) ->
  console.log source, type
  chrome.tabs.executeScript {code:
    "var script = document.createElement('script');
     script.id = 'mediaFunctions';
     script.text = 'function play() {
                media.play();
            }
            function pause() {
                media.pause();
            }
            media = new #{type}(\\'#{source}\\');';

     var play = document.createElement('script');
     play.id = 'playMedia';
     play.text = 'media.play()';

     document.body.appendChild(script);
     document.body.appendChild(play);
"}

place = (source) ->
  chrome.tabs.executeScript {code: "
    document.getElementById('#{source}').focus();
"}, ->
    chrome.tts.speak('Write')

click = (source) ->
  chrome.tabs.executeScript {code: "
    try{
      new URL('#{source}');
      window.location = '#{source}'
    }
    catch (_){
      document.getElementById('#{source}').click();
    }
"}

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

#listen for RDFa elements
chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  content = request.test
  console.log request.test #todo

  elements = {}
  mark = 0
  for element in content
    #Skip declarations

    try
      node = addElement(element)
    catch _
      continue

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
    notifications: [],
    nodes: elements

  console.log 'background.coffee'
  console.log elements
  readMenu(elements['elements'], 0)
  chrome.storage.local.set {tree: elements}

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
  console.log command
  chrome.tts.stop()

  #Before we use the new command, stop any previous commands
  chrome.tabs.executeScript {file: 'pause.js'}, ->

    chrome.storage.local.get ['tree'], (result) ->
      elements = result.tree
      if not elements? #The tree is still not generated
        console.log 'no elements'
        return

      keyPress = -1
      prev = false
      switch command
        when 'first' then keyPress = 0
        when 'second' then keyPress = 1
        when 'third' then keyPress = 2
        when 'fourth' then keyPress = 3
        when 'more' then keyPress = 4
        when 'previous' then prev = true
        when 'repeat' then readMenu(elements['elements'], elements['index'])

      index = elements['index']
      if keyPress != -1
        menu = elements['elements']
        notification = elements['notification']

        len = menu.length

        if keyPress == 4
          index += 4
          elements['index'] = index

          readMenu(elements['elements'], index)
          chrome.storage.local.set {tree: elements}
        else if index + keyPress < len
          index = index + keyPress
          list = onAction(menu[index])

          if list?
            elements =
              elements: list,
              index: 0,
              notifications: [],
              nodes: elements['nodes']

            chrome.storage.local.set {tree: elements}
            readMenu(elements['elements'], 0)
      else if prev
        if index != 0
          index -= 4
          elements =
            elements: elements['elements'],
            index: index,
            notifications: [],
            nodes: elements['nodes']

          chrome.storage.local.set {tree: elements}
        else
          list = getParent(elements)
          elements =
            elements: list,
            index: index,
            notifications: [],
            nodes: elements['nodes']

          chrome.storage.local.set {tree: elements}


        readMenu(elements['elements'], index)

      console.log elements
