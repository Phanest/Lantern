#classes
#todo add parents to children
#todo children, onAction

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