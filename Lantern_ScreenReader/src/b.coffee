script = document.getElementById('mediaFunctions');
play = document.getElementById('playMedia');

if play? and script?
  pause = document.createElement('script')
  pause.text = 'media.pause()'

  play.parentNode.removeChild(play)
  document.body.appendChild(pause)
  document.body.removeChild(pause)
  script.parentNode.removeChild(script)