{% if theme.theme.fancybox %}
  {% set fancybox_js = 'fancybox/jquery.fancybox.pack.js' %}
{% endif %}

{%
  set js_libs = {
    jquery: 'jquery/jquery-3.1.1.min.js',
    slideout: 'slideout/slideout.js',
    fancybox: fancybox_js
  }
%}

{% for lib in js_libs %}
  {% if lib %}
    <script type="text/javascript" src="{{ url_for('lib') }}/{{ lib }}"></script>
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
<script type="text/javascript" async src="//cdn.bootcss.com/mathjax/2.7.0/MathJax.js?config=TeX-AMS-MML_HTMLorMML" integrity="sha384-crwIf/BuaWM9rM65iM+dWFldgQ1Un8jWZMuh3puxb8TOY9+linwLoI7ZHZT+aekW" crossorigin="anonymous"></script>
