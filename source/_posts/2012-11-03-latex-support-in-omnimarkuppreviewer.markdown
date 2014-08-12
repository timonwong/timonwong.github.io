---
layout: post
title: "$\\LaTeX$ Support in OmniMarkupPreviewer"
date: 2012-11-03 12:41
categories: IT
tags: [Sublime Text 2, Sublime Text 3, OmniMarkupPreviewer]
---

Prologue
--------

With the release of [OmniMarkupPreviewer] `v1.6`, you can embed $\LaTeX$ and MathML equations directly into your Markdown documents. Equations are handled with the excellent [MathJax] library.

[OmniMarkupPreviewer]: http://theo.im/OmniMarkupPreviewer/
[MathJax]: http://www.mathjax.org/

<!-- more -->

Usage
-----

### Settings

In order to enable MathJax, you have to set `"mathjax_enabled"` to `true` in your OmniMarkupPreviewer settings. MathJax will be downloaded automatically in the background, so hold on.

`OmniMarkupPreviewer.sublime-settings`:

``` javascript
{
    "mathjax_enabled": true
}
```

**NOTE (Linux)**
For linux users, because ssl module is missing from Linux version of [Sublime Text 2], you have to download and extract MathJax library manually:

[Sublime Text 2]: http://sublimetext.com/2

Download the MathJax archive:

``` bash
wget -c https://github.com/downloads/timonwong/OmniMarkupPreviewer/mathjax.zip
```

Extract to `${packages}/OmniMarkupPreviewer/public/`:

``` bash
unzip mathjax.zip -d ~/.config/sublime-text-2/Packages/OmniMarkupPreviewer/public
```

Create an empty file named `.MATHJAX.DOWNLOADED` in the plugin folder:

``` bash
touch ~/.config/sublime-text-2/Packages/OmniMarkupPreviewer/.MATHJAX.DOWNLOADED
```

After MathJax is installed successfully, you have to **reload** your browser to apply the changes.

### Writing Equations

#### Inline Equations

Enclose your euqation in `$` delimiters to include an inline $\LaTeX$ equation, for example:

``` plain
This expression $\sqrt{3x-1}+(1+x)^2$ is an example of a $\LaTeX$ inline equation.
```

This expression $\sqrt{3x-1}+(1+x)^2$ is an example of a $\LaTeX$ inline equation.

Alternatively, native MathJax delimiter for inline math (`\(` and `\)`) is also supported.

#### Display Equations

To include a $\LaTeX$ display equation you have to enclose the equation in `$$` delimiters, for example:

``` plain
The Lorenz Equations:

$$
\begin{aligned}
\dot{x} & = \sigma(y-x) \\
\dot{y} & = \rho x - y - xz \\
\dot{z} & = -\beta z + xy
\end{aligned}
$$
```

{% rawblock %}
$$
\begin{aligned}
\dot{x} & = \sigma(y-x) \\
\dot{y} & = \rho x - y - xz \\
\dot{z} & = -\beta z + xy
\end{aligned}
$$
{% endrawblock %}

The alternative syntax of native MathJax delimiter for display math (`\[` and `\]`) is also provided.

#### MathML Equations

You can alsow insert MathML euqations, just wrap your equation inside the standard `<math>` tag:

``` xml
<math xmlns="http://www.w3.org/1998/Math/MathML" display="block">
  <mi>P</mi>
  <mo stretchy="false">(</mo>
  <mi>E</mi>
  <mo stretchy="false">)</mo>
  <mo>=</mo>
  <mrow class="MJX-TeXAtom-ORD">
    <mfenced open="(" close=")">
      <mfrac linethickness="0">
        <mi>n</mi>
        <mi>k</mi>
      </mfrac>
    </mfenced>
  </mrow>
  <msup>
    <mi>p</mi>
    <mi>k</mi>
  </msup>
  <mo stretchy="false">(</mo>
  <mn>1</mn>
  <mo>&#x2212;<!-- − --></mo>
  <mi>p</mi>
  <msup>
    <mo stretchy="false">)</mo>
    <mrow class="MJX-TeXAtom-ORD">
      <mi>n</mi>
      <mo>&#x2212;<!-- − --></mo>
      <mi>k</mi>
    </mrow>
  </msup>
</math>
```
