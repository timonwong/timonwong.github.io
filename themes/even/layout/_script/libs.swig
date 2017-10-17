{% if theme.theme.fancybox %}
  {% set fancybox_js = 'https://cdn.bootcss.com/fancybox/2.1.5/jquery.fancybox.pack.js' %}
{% endif %}

{%
  set js_libs = {
    jquery: 'https://cdn.bootcss.com/jquery/3.1.1/jquery.min.js',
    slideout: 'https://cdn.bootcss.com/slideout/1.0.1/slideout.js',
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
<script type="text/javascript" async src="https://cdn.bootcss.com/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML" integrity="sha384-Ra6zh6uYMmH5ydwCqqMoykyf1T/+ZcnOQfFPhDrp2kI4OIxadnhsvvA2vv9A7xYv" crossorigin="anonymous"></script>
