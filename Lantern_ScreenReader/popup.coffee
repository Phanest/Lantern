#popups, contentscripts and background can interact with eachother by sending messages and setting storage

changeColor = document.getElementById('changeColor')

#data becomes an object with keys as properties
#after we get the storage 'color', we call a function
chrome.storage.sync.get 'color', (data) ->
  changeColor.style.backgroundColor = data.color
  #This sets up an attribute called value, used below
  changeColor.setAttribute 'value', data.color

changeColor.onclick = (element) ->
  color = element.target.value
  chrome.tabs.query {active: true, currentWindow: true}, (tabs) ->
    chrome.tabs.executeScript tabs[0].id, {code: 'document.body.style.backgroundColor = "' + color + '";'}
