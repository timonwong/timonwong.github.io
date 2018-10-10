{% if theme.theme.fancybox %}
  {% set fancybox_js = 'https://cdn.staticfile.org/fancybox/2.1.5/jquery.fancybox.pack.js' %}
{% endif %}

{%
  set js_libs = {
    jquery: 'https://cdn.staticfile.org/jquery/3.1.1/jquery.min.js',
    slideout: 'https://cdn.staticfile.org/slideout/1.0.1/slideout.min.js',
    fancybox: fancybox_js
  }
%}

{% for lib in js_libs %}
  {% if lib %}
    <script type="text/javascript" src="{{ lib }}"></script>
  {% endif %}
{% endfor %}

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {
      processEscapes: true,
      inlineMath: [ ['$','$'], ['\\(','\\)'] ],
      skipTags: [ 'script', 'noscript', 'style', 'textarea', 'pre', 'code' ]
    }
  });
</script>
<script type="text/javascript" async src="https://cdn.staticfile.org/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML" integrity="sha384-Ra6zh6uYMmH5ydwCqqMoykyf1T/+ZcnOQfFPhDrp2kI4OIxadnhsvvA2vv9A7xYv" crossorigin="anonymous"></script>
