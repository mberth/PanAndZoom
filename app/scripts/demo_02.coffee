#<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
#<script type="text/x-mathjax-config">MathJax.Hub.Config({ tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});</script>


# Motion on a circle
# ------------------

# We want to rotate graphical objects at varying speeds to produce
# interesting visual effects.

# Compute a point's position from its angle $\alpha$ and radius $r$ according to
# $$(x,y) = r \, (\cos \alpha, \sin \alpha)$$
position = (alpha, radius) ->
  [radius * Math.cos(alpha), radius * Math.sin(alpha)]