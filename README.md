
[![Build Status](https://travis-ci.org/waebbl/waebbl-gentoo.svg?branch=master)](https://travis-ci.org/waebbl/waebbl-gentoo)

# gentoo-overlay

This is my personal overlay of gentoo ebuilds. It has some focus on the domain 3D, i.e. you will find mostly ebuilds for modeling and CAx software, but also some other ebuilds, which are either not in the official portage tree, or with whom I had trouble compiling them from official tree.

You can expect reasonable high quality ebuilds here, although some might not reach gentoo QA standards. Feel free to open an issue, whenever you find an ebuild is not working properly.

**Note:** To emerge the freecad package, you need the pyside packages from the `::raiagent` overlay at https://github.com/leycec/raiagent.git. Use `eselect repository enable raiagent` before emerging freecad.


See the [TODO](TODO.md) file for a list of what I'm currently working on or planning to do.
