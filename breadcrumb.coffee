class window.Breadcrumb
  _makeCrumb: (x, y, text, active) ->
    arrowWidth = 15
    isStart = true
    padding = 30
    if typeof(x) == 'object'
      isStart = false
      box = x.getBBox()
      x = box.x + box.width - arrowWidth
    x = parseInt(x)
    fontSize = 15
    s = @r.print(0, 0, text, @r.getFont("Museo Sans 500"), fontSize)
    w = parseInt(s.getBBox().width + (padding * 2) + arrowWidth)
    s.remove()
    if isStart
      w = w - arrowWidth
    height = 20
    if active
      height = height + 2
      y = y - 2
      arrowWidth = arrowWidth + 1
      x = x - 2
      fontSize = fontSize + 2
    path = "M "+x+" "+y+" l "+w+" 0 l "+arrowWidth+" "+height+" l -"+arrowWidth+" "+height+" l -"+w+" 0 "
    if isStart
      path += "s -5 0 -5 -5 l 0 -"+((height * 2) - 10)+" s 0 -5 5 -5"
    else
      path += "l "+arrowWidth+" -"+height+" z"
    c = @r.path(path)
    c.path = path
    if active
      c.attr(
        gradient: '90-#236aa7-#31abd2'
        'stroke-linejoin': 'round'
        'stroke-width': 0
      )
      y = y + 2
    else
      c.attr(
        gradient: '90-#b3b6b5-#ffffff'
        'stroke-width': 1
        cursor: 'pointer'
        stroke: '#a3a6a5'
      )
    box = c.getBBox()
    ty = parseInt(box.y + (box.height / 2))
    if active
      ty = ty - 1
    if isStart
      c.mytext = @r.print(x+padding, ty, text, @r.getFont("Museo Sans 500"), fontSize)
    else
      c.mytext = @r.print(x+padding + arrowWidth, ty, text, @r.getFont("Museo Sans 500"), fontSize)
    if active
      c.mytext.attr({fill: '#fff'})
    else
      c.blanket = @r.rect().attr(c.mytext.getBBox()).attr({fill: "#000", opacity: 0, cursor: 'pointer'}).click () ->
        c.makeActive()
    return c

  _makeSection: (x, y, text, cb) ->
    el = @_makeCrumb(x, y, text)
    el.makeActive = () =>
      if !el.disabled
        if @current
          cloned = @current.active.clone()
          @current.active.hide()
          @current.active.mytext.hide()
          attr = el.active.attr()
          el.active.mytext.attr({fill: '#236aa7'}).animate({fill: '#fff'}, 700, 'easeOut')
          cloned.animate {path: attr.path}, 250, 'easeOut', () =>
            @current = el
            @current.active.show()
            @current.active.mytext.show()
            cloned.remove()
            cb?()
        else
          @current = el
          @current.active.show()
          @current.active.mytext.show()
          cb?()
    el.makeDisabled = () =>
      unless el.disabled
        el.disabled = true
        el.attr({gradient: '90-#ddd-#ddd', cursor: 'not-allowed'})
        el.mytext.attr({fill: '#aaa'})
        el.blanket.attr({cursor: 'not-allowed'})
    el.makeEnabled = () =>
      if el.disabled
        el.disabled = false
        el.attr({gradient: '90-#b3b6b5-#ffffff', cursor: 'pointer'})
        el.mytext.attr({fill: '#000'})
        el.blanket.attr({cursor: 'pointer'})
    el.node.onclick = el.makeActive
    el.active = @_makeCrumb(x, y, text, true)
    el.active.hide()
    el.active.mytext.hide()
    return el

  make: (text, cb) ->
    x = 10
    if @previous
      x = @previous
    y = 10
    section = @_makeSection(x, y, text, cb)
    @sections[text] = section
    @previous = section
    return section

  get: (text) ->
    return @sections[text]

  constructor: (id) ->
    @sections = {}
    @r = Raphael(id)
