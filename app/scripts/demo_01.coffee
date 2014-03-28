# Motion on a circle
# ------------------

# We want to rotate graphical objects at varying speeds to produce
# interesting visual effects.

# Compute a point's position from its angle alpha and radius.
position = (alpha, radius) ->
  [radius * Math.cos(alpha), radius * Math.sin(alpha)]