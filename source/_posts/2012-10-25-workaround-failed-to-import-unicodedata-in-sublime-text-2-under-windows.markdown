---
layout: post
title: "Workaround: Failed to import unicodedata in Sublime Text 2 under Windows"
date: 2012-10-25 13:36
comments: true
categories: [Sublime Text 2]
---

It's weird, while importing some .pyd modules, like pyexpat, unicodedata in Windows
version of [Sublime Text 2](http://www.sublimetext.com/2), you will get ``ImportError``,
for example:

``` python
import unicode
```

Will result in:
```
Import Error: No module named unicode
```

However, since standard pyd modules are not missing, reside correctly in the same
folder as sublime_text.exe, we can add that folder to sys.path in order to allow
embedded python interpreter to load these modules:

``` python
sys.path.insert(os.path.dirname(sys.executable))
```

After that, you can import these standard python modules without pain, I hope it's
useful for Sublime Text 2 packages developers who met the same problem before.
