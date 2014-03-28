#<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
#<script type="text/x-mathjax-config">MathJax.Hub.Config({ tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});</script>

# We want to rotate graphical objects at varying speeds to produce
# interesting visual effects.
define ['paper'], (paper) ->  # package everything as a RequireJS module

  # Rotating objects
  # ----------------

  # Compute a point's position from its angle $\alpha$ and radius $r$ according to
  # $$(x,y) = r \, (\cos \alpha, \sin \alpha)$$
  position = (alpha, radius) ->
    [radius * Math.cos(alpha), radius * Math.sin(alpha)]

  # Rotate a Paper.js item around a rotation center.
  rotate = (item, alpha, radius, center) ->
    item.position = position(alpha, radius)
    item.translate center
    item

  # The animation
  # -------------

  example = (canvasID) ->
    # Setup the canvas
    canvas = document.getElementById(canvasID)
    paper.setup canvas

    # Create two circles
    circle1 = new paper.Path.Circle center: [100,100], radius: 10, fillColor: "green"
    circle2 = new paper.Path.Circle center: [100,100], radius: 20, fillColor: "indigo"

    # Rotate circles on every animation frame. The `paper.view.onFrame` function is
    # called approximately 60 times per second.
    alpha = 0
    paper.view.onFrame = ->
      rotate circle1, 1.1*alpha, 50, [200, 100]
      rotate circle2,    -alpha, 30, [200, 120]
      alpha = (alpha + 0.05)

  # <canvas id="paper1" width="400" height="200" style="background: lightgray;"></canvas>

  # Return the example as a function that can be used via RequireJS.
  example


# <script data-main="../scripts/demo_main" src="../../bower_components/requirejs/require.js"></script>