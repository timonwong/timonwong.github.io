---
layout: post
title: "Directory comparison for git difftool, with Beyond Compare 3"
date: 2012-10-27 23:02
comments: true
categories: [Git]
---

For a long time, I didn't know a way to do directory comparison using git difftool command,
[extdiff extension](http://mercurial.selenic.com/wiki/ExtdiffExtension) from
Mercurial did perform much more superior than Git.

Though it may be a bit out of date, I just found that after v1.7.11, Git now supports
directory comparison through `--dir-diff` option, fantastic!

So here is a list of steps for me to make Beyond Compare 3 and Git
([msysgit](http://code.google.com/p/msysgit/downloads/list)) directory comparison
work under Windows.

You may need to change the folder where `BCompare.exe` resides.

```
git config --global diff.tool bc3
git config --global difftool.bc3.cmd "\"c:/Program Files/Beyond Compare 3/BCompare.exe\" \"$LOCAL\" \"$REMOTE\""
git config --global difftool.prompt false
```

**NOTE**
Instead of `bcomp.exe`, using `BCompare.exe`, because I've found `bcomp.exe` returns
too early, which cause an error like this:

```
...Git/libexec/git-core\git-difftool line 444: Bad file number
```

Then make an alias for difftool:

```
git config --global alias.dt "difftool --dir-diff"
```

Now, you can use `git dt` to open Beyond Compare 3 for directory comparison in git repositories.
