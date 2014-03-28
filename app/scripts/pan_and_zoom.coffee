#<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
#<script type="text/x-mathjax-config">MathJax.Hub.Config({ tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});</script>

# Here is a straight forward implementation for panning and zooming in a [paper.js](http://paperjs.org/) drawing.
# Try it: shift-mousewheel moves the box around,
# alt-mousewheel zooms in and out.

# <canvas id="paper1" width="600" height="300" style="background: gray;"></canvas>
# <script data-main="../scripts/main" src="../../bower_components/requirejs/require.js"></script>

# Now try to zoom in on the circle -- the circle moves away from the mouse pointer.
# You would expect the drawing to zoom in around your mouse pointer, as is shown
# in the [stable zoom](#StableZoom) example below.

# By default, paper.js zooms in around the center of the view. The initial view center
# is marked by the small square. When you pan around the center of the view changes,
# try zooming in and out after panning.

# The simple implementation works like this: get the mousewheel movements from the
# [jQuery Mouse Wheel Plugin](https://github.com/brandonaaron/jquery-mousewheel).
# Then use `paper.view.center = (x,y)` to move around, and
# `paper.view.zoom = z` to zoom in and out (see the paper.js docs for
# [View.zoom](http://paperjs.org/reference/view/#zoom) and
# [View.center](http://paperjs.org/reference/view/#center)).

# By the way: this post
# shows [coffeescript](http://coffeescript.org/) code, mixed with explanations and working examples such as
# the one above.
# It was generated from a single [coffeescript input file](https://github.com/mberth/PanAndZoom/blob/master/app/scripts/pan_and_zoom.coffee)
# with [docco](http://jashkenas.github.io/docco/). I'll explain in detail how this works in a
# forthcoming blog post.

# <a name="SimplePanAndZoom"></a>Simple Panning and Zooming
# --------------------------


define ['paper', 'jquery-mousewheel'], (paper) ->  # package as a RequireJS module

  # A simple implementation of pan and zoom: just change the
  # zoom factor or the view center.
  class SimplePanAndZoom
    # The zoom and pan logic is extracted into functions that
    # produce the new zoom (or center) given the old zoom (or center) and mouse wheel deltas.

    # Compute the new zoom factor from the old
    # zoom factor and some delta that is given to us by the mousewheel plugin.
    changeZoom: (oldZoom, delta) ->
      factor = 1.05
      if delta < 0
        return oldZoom * factor
      if delta > 0
        return oldZoom / factor
      oldZoom

    # Compute the new center from old center and the delta given by the mousewheel plugin.
    changeCenter: (oldCenter, deltaX, deltaY, factor) ->
      offset = new paper.Point deltaX, -deltaY
      offset = offset.multiply factor
      oldCenter.add offset


  # <a name="Example1"></a>Example 1
  # --------------------------------

  # Here is the code that produces the example above. Feel free to skip ahead to
  # the [stable zoom](#StableZoom).

  # Draw a grid with major and minor lines
  drawGrid = (width, height) ->
    new paper.Path.Rectangle from: [0, 0], to: [width, height], fillColor: 'white'
    # Style: thick major grid lines, thin minor lines
    lineStyle = (coord) ->
      if coord % 50 == 0
        {strokeColor: 'lightblue', strokeWidth: 2}
      else
        {strokeColor: 'lightblue', strokeWidth: 1}
    # Draw vertical lines
    for x in [0..width] by 10
      line = new paper.Path.Line segments: [[x, 0], [x, height]]
      line.set lineStyle(x)
    # Draw horizontal lines
    for y in [0..height] by 10
      line = new paper.Path.Line segments: [[0, y], [width, y]]
      line.set lineStyle(y)

  example1 = (canvasID) ->
    # Setup the `paper` object
    canvas = document.getElementById(canvasID)
    paper.setup canvas
    # Remember the current view so we can access it in event handlers.
    view = paper.view

    # Create a grid and a circle.
    width = 600
    height = 300
    drawGrid width, height
    new paper.Path.Circle center: [100, 100], radius: 20, fillColor: 'green'
    box = new paper.Path.Rectangle from: [0,0], to: [10,10], fillColor: 'gray'
    box.position = view.center

    # Use a `SimplePanAndZoom` to translate from mouse events to changes in the view.
    panAndZoom = new SimplePanAndZoom()

    # We use the jquery-mousewheel plugin to get the events.
    $("##{canvasID}").mousewheel (event) ->
      if event.shiftKey
        view.center = panAndZoom.changeCenter view.center, event.deltaX, event.deltaY, event.deltaFactor
        event.preventDefault()
      else if event.altKey
        view.zoom = panAndZoom.changeZoom view.zoom, event.deltaY
        event.preventDefault()


    # When using paper.js from javascript directly, you have to call
    # `view.draw()` to draw the scene.
    view.draw()


  # <a name="StableZoom"></a>Stable Zoom
  # ------------------------------------

  # Try zooming in on the circle (again shift-mousewheel moves the box around,
  # alt-mousewheel zooms in and out). The drawing zooms in around your mouse pointer.

  # <canvas id="paper2" width="600" height="300" style="background: gray;"></canvas>

  # Let's derive the formula for this systematically.
  # The default paper.js zoom has the view's center as a fixed point.
  # Write the default zoom transform as some function $Z$ and call the view's center point $c$.
  # Then we have
  # $$Z(c) = c$$
  # We want to apply the default zoom and then correct it by a translation that makes sure
  # the point under the mouse $p$ stays where it is.
  # We are looking for a translation vector $a$ such that
  # $$Z(p) + a = p$$
  # This means that the correction has to be $a = p - Z(p)$.

  # How do we get a formula for the default zoom transform $Z$?
  # It is a scaling that has the view center $c$ as a fixed point.
  # This can be done by shifting $c$ to the origin, then scaling by a factor $\beta$ then shifting back to $c$:
  # $$Z(x) = \beta \cdot (x - c) + c$$
  # You can check that indeed $Z(c) = c$.

  # With that our correction becomes
  # $$a = p - Z(p) = p - \beta \cdot (p - c) - c$$

  # Make a subclass of `SimplePanAndZoom` for stable zooming.
  class StableZoom extends SimplePanAndZoom

    # Compute the new zoom factor such that a given fixedPoint $p$ is unchanged.
    # `oldZoom` is the current zoom factor, `delta` gives how much the mousewheel was turned
    # $c$ is the old view center. We use the paper.js methods for computing with points (vectors).
    changeZoom: (oldZoom, delta, c, p) ->
      newZoom = super oldZoom, delta
      beta = oldZoom / newZoom
      pc = p.subtract c
      a = p.subtract(pc.multiply(beta)).subtract c
      [newZoom, a]

  # Example 2
  # ---------

  example2 = (canvasID) ->
    # Setup the `paper` object
    canvas = document.getElementById(canvasID)
    paper.setup canvas
    # Remember the current view so we can access it in event handlers.
    view = paper.view

    # Create a grid and a circle.
    width = 600
    height = 300
    drawGrid width, height
    new paper.Path.Circle center: [100, 100], radius: 20, fillColor: 'teal'

    # Use a `StableZoom` to translate from mouse events to changes in the view.
    panAndZoom = new StableZoom()

    # We use the jquery-mousewheel plugin to get the events.
    $("##{canvasID}").mousewheel (event) ->
      if event.shiftKey
        view.center = panAndZoom.changeCenter view.center, event.deltaX, event.deltaY, event.deltaFactor
        event.preventDefault()
      else if event.altKey
        mousePosition = new paper.Point event.offsetX, event.offsetY
        # We use `viewToProject()`, an undocumented paper.js function that converts mouse coordinates
        # to project coordinates. When you use the
        # [paper.js event handling](http://paperjs.org/tutorials/interaction/creating-mouse-tools/)
        # this conversion is already done for you.
        viewPosition = view.viewToProject(mousePosition)
        [newZoom, offset] = panAndZoom.changeZoom view.zoom, event.deltaY, view.center, viewPosition
        view.zoom = newZoom
        view.center = view.center.add offset
        event.preventDefault()
        view.draw()

    # When using paper.js from javascript directly, you have to call
    # `view.draw()` to draw the scene.
    view.draw()

  # Finally, make the examples available via RequireJS.
  {example1: example1, example2: example2}