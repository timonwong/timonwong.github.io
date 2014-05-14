---
layout: post
title: "Directory comparison for git difftool, with Beyond Compare 3"
date: 2012-10-27 23:02
categories: IT
tags: [Git, Beyond Compare 3]
---

For a long time, I didn't know a way to do directory comparison using git difftool command,
[extdiff extension](http://mercurial.selenic.com/wiki/ExtdiffExtension) from
Mercurial did perform much more superior than Git.

Though it may be a bit out of date, I just found that after `v1.7.11`, Git now supports
directory comparison through `--dir-diff` option, fantastic!

**UPDATE 12/11/2012:** You will need v1.8.0 version of [msysgit] installed, as noted by **Scooter Software** ([Reference](http://www.scootersoftware.com/vbulletin/showthread.php?t=9449)).

So here is a list of steps for me to make Beyond Compare 3 and Git directory comparison
work under Windows.

First of all, Execute following commands in the `Git Bash` shell (or just modify your .gitconfig directly).
You may need to change the folder where `BCompare.exe` resides.

```
git config --global diff.tool bc3
git config --global difftool.bc3.cmd "\"c:/Program Files/Beyond Compare 3/BCompare.exe\" \"$LOCAL\" \"$REMOTE\""
git config --global difftool.prompt false
```

**NOTE:** Instead of `bcomp.exe`, use `BCompare.exe`, because I've found `bcomp.exe` returns
too early, which will cause errors like this:

```
...Git/libexec/git-core\git-difftool line 444: Bad file number
```

Then make an alias for difftool:

```
git config --global alias.dt "difftool --dir-diff"
```

Now, you can use `git dt` to open Beyond Compare 3 for directory comparison in git repositories.

[msysgit]: http://code.google.com/p/msysgit/downloads/list
