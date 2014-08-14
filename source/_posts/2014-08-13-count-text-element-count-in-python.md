title: 在 Python 中统计文本字符个数
date: 2014-08-13 14:05:02
categories: IT
tags: [Python, Unicode]
---

字符集向来都是一个大问题，即使是 Python 3.x，也最多只是能说感谢 [Unicode] 字符集，字符串的存取现在没有问题了。

Unicode 字符集的常见**编码**有 [UTF-8]、[UTF-16]、[UTF-32] 等常见格式，另外，[GB18030] 也可以算其中一种（ GB18030，与 UTF-8 类似，是一种变长编码格式，最大的优势就是兼容 [GBK]/[GB2312] ）

但是 Unicode 就能无痛的解决所有问题吗？答案是否定的。

<!--more-->

### 吐槽吐槽吐槽 ###

题外话，对于传统的 MBCS 编码，总得说来 GBK 设计算是比较合理的，至少在 0x00 ~ 0x7f 的 ASCII 区间里面没有乱来。
BIG5 就不说了，“许功盖” 问题大家都知道，简直鬼火冒。这里就来吐槽一下 Shift-JIS 和 EUC-KR：

**Shift-JIS:**

| First byte |  ASCII  |Shift JIS
|:----------:|:-------:|:-----:|
|    0x5c    |   `\`   |  `¥`  |
|    0x7e    |   `~`   |  `‾`  |

**EUC-KR:**

| First byte |  ASCII  | EUC-KR
|:----------:|:-------:|:-----:|
|    0x5c    |   `\`   |  `₩`  |

满眼都是钱钱钱，呵呵，打住。

### 正文正文正文 ###

其它的先暂且不提，就说怎么统计字符个数吧（文本元素个数）。在 Python 中，往往想到的就是使用 `len()` 函数了：


``` python
s = '中文'
len(s) # 呵呵...
```
明智的人类知道有 Unicode，就可以把 Unicode 搬出来了，哪怕这个问题其实跟编码没有什么关系：

> 用 Unicode 就好了，要不就使用 Python 3 字符串原生使用 Unicode，无痛解决所有问题

Cooooooooooooool，让我们来试试：

``` python
# -*- coding: utf-8 -*-
s1 = u'中文'
assert len(s1) == 2  # Wow, 看起来对了是吧，让我们弹冠相庆吧

s2 = u'𤴐𪚥'
len(s2) # 呵呵呵...
```

天才的人类知道 UCS-2 和 UCS-4 的区别：

> 谁叫你用 Windows 呢，只能用 UTF-16，弱爆了， Linux 下用 UCS-4 就能解决问题了

Sure? 举一个反例就可以了：

``` python
import sys

assert sys.maxunicode == 0x10ffff  # 保证是通过 UCS-4 编译的

# 这样，常见字，没有问题，GOOD
assert len(u'中文') == 2

# 这样，生僻字，Non BMP，也没有问题, GOOD
assert len(u'𤴐𪚥') == 2

# 欢迎来到 Unicode 的世界, 不要忘了 Unicode 有叫 Mark 的这种东西
assert len(u'ë́') == 2

```

![](http://theo-im.qiniudn.com/images/yaoming-face.jpg)

所以最怕半罐水了（当然也包括我自己，太可怕了）。

### Show Me The Source Code ###

在 .Net Framwork 里，有一个叫 String.Globalization.StringInfo 的类可以处理上面的情况。
由于我本人比较懒，就直接参考 Mono 的代码写了，Mono 的代码可以[点击这里查看](https://github.com/mono/mono/blob/master/mcs/class/corlib/System.Globalization/StringInfo.cs)。

为了避免系统的编码问题，推荐保存为文件('stringinfo.py')，再使用 Python 解析器执行：


``` python stringinfo.py
import unicodedata
import sys

__all__ = ['UnicodeCategory', 'StringInfo']

PY3K = sys.version_info[0] >= 3

if PY3K:
    unicode_type = str
else:
    unicode_type = unicode


class UnicodeCategory(object):
    """General Category for Unicode

    http://www.unicode.org/versions/Unicode6.0.0/ch04.pdf
    """

    # Letter
    UppercaseLetter = 'Lu'
    LowercaseLetter = 'Ll'
    TitlecaseLetter = 'Lt'
    ModifierLetter = 'Lm'
    OtherLetter = 'Lo'
    # Mark
    NonSpacingMark = 'Mn'
    SpacingCombiningMark = 'Mc'
    EnclosingMark = 'Me'
    # Number
    DecimalDigitNumber = 'Nd'
    LetterNumber = 'Nl'
    OtherNumber = 'No'
    # Separator
    SpaceSeparator = 'Zs'
    LineSeparator = 'Zl'
    ParagraphSeparator = 'Zp'
    # Punctuation
    ConnectorPunctuation = 'Pc'
    DashPunctuation = 'Pd'
    OpenPunctuation = 'Ps'
    ClosePunctuation = 'Pe'
    InitialQuotePunctuation = 'Pi'
    FinalQuotePunctuation = 'Pf'
    OtherPunctuation = 'Po'
    # Symbol
    MathSymbol = 'Sm'
    CurrencySymbol = 'Sc'
    ModifierSymbol = 'Sk'
    OtherSymbol = 'So'
    # Other
    Control = 'Cc'
    Format = 'Cf'
    Surrogate = 'Cs'
    PrivateUse = 'Co'
    OtherNotAssigned = 'Cn'


class StringInfo(object):
    def __init__(self, s):
        if not isinstance(s, unicode_type):
            raise TypeError("'string' parameter must be unicode")
        self.s = s

    @property
    def length_in_text_elements(self):
        """Gets the number of text elements."""
        l = getattr(self, '_length_in_text_elements', None)
        if l is None:
            l = sum(1 for _ in self.text_element_length_generator(self.s))
            setattr(self, '_length_in_text_elements', l)
        return l

    @classmethod
    def text_element_length_generator(cls, s):
        """Gets the text element index generator of the specified string."""
        if not isinstance(s, unicode_type):
            raise TypeError("parameter 's' must be unicode")

        marks = set([UnicodeCategory.NonSpacingMark,
                     UnicodeCategory.SpacingCombiningMark,
                     UnicodeCategory.EnclosingMark])

        idx = 0
        while idx < len(s):
            ch = s[idx]
            count = 1
            cat = unicodedata.category(ch)

            if cat == UnicodeCategory.Surrogate:
                # Check that it's a high surrogate followed by a low surrogate
                if 0xd800 <= ord(ch) <= 0xdbff:
                    if (idx + 1) < len(s) and \
                            0xdc00 <= ord(s[idx + 1]) <= 0xdfff:
                        # A valid surrogate pair
                        count = 2
            else:
                # Look for a base character, which may or may not be followed by a
                # series of combining characters
                if cat not in marks:
                    while idx + count < len(s):
                        cat = unicodedata.category(s[idx + count])
                        if cat not in marks:
                            # Finished the sequence
                            break
                        count += 1
            yield count
            idx += count

    @classmethod
    def text_element_generator(cls, s):
        """Gets the text element generator of the specified string."""
        idx = 0
        for length in cls.text_element_length_generator(s):
            yield s[idx:idx+length]
            idx += length
```

然后简单测试一下：

``` python
# -*- coding: utf-8 -*-
from __future__ import print_function

import unicodedata
import sys

from stringinfo import StringInfo


def main():
    if sys.maxunicode > 0xffff:
        print("Unicode encoding is UTF-32")
    else:
        print("Unicode encoding is UTF-16")

    s = u"ë́中文𤴐𪚥"
    print(len(s))  # 根据 Python 是否启用 UCS-4，结果不同，UTF-16 下是 8，UCS-4 下是 6
    print(StringInfo(s).length_in_text_elements)  # 5个字符
    for c in s:
        print('U+{:04X}:{}'.format(ord(c), unicodedata.category(c)))


if __name__ == '__main__':
    main()
```

╮(╯_╰)╭ 终于舒服了。

~FIN~


[Unicode]: http://en.wikipedia.org/wiki/Unicode
[UTF-8]: http://en.wikipedia.org/wiki/UTF-8
[UTF-16]: http://en.wikipedia.org/wiki/UTF-16
[UTF-32]: http://en.wikipedia.org/wiki/UTF-32
[GB18030]: http://en.wikipedia.org/wiki/GB_18030
[GBK]: http://en.wikipedia.org/wiki/GBK
[GB2312]: http://en.wikipedia.org/wiki/GB2312
