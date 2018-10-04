## Packages to check and possibly include

- [ ] [sci-libs/trilinos](https://github.com/trilinos/Trilinos) available in science overlay in current version. Possibly no need for another package
- [ ] [sci-libs/mumps](http://mumps.enseeiht.fr) availabe in science overlay in outdated version, needs manual download?
- [ ] [dev-util/tribits](https://github.com/TriBITSPub/TriBITS) new package: improvement to cmake for large scale, multi-repository projects
- [ ] [sci-misc/elmer](https://github.com/ElmerCSC/elmerfem) available in science overlay in outdated version as meta and subpackages. Possibly only need one package with latest version
- [ ] [net-im/quaternion](https://github.com/QMatrixClient/Quaternion) new package: Qt5 client for matrix protocol
- [ ] [dev-util/codespell](https://github.com/codespell-project/codespell) new package: tool to check spelling in code files
- [ ] [sci-mathematics/salome-meta](https://salome-platform.org/) new package: probably use salome-platform as package name without the need for meta and subpackages. Tool for numerical simulation. Currently the subpackage sci-libs/libmed is available
- [ ] [media-libs/smesh](https://salome-platform.org/) new package: possibly make separate smesh package from salome platform first, for use in freecad
- [ ] [sci-mathematics/ngsolve](https://github.com/NGSolve/ngsolve) new package: FEM tools tied to sci-libs/netgen
- [ ] [sci-visualization/knossos](https://github.com/knossos-project/knossos) new package: visualization and annotation of 3D image data.
- [ ] [app-arch/zipios](https://github.com/Zipios/Zipios) new package: used by freecad, currently internal package is used
- [ ] [media-gfx/makehuman](https://github.com/makehumancommunity/makehuman) new package: take a look at cg overlay, if their ebuild is usable
- [ ] [media-gfx/solvespace](https://github.com/solvespace/solvespace) new package: parametric 2D/3D CAD package

## Packages which need updating

- [ ] dev-libs/tvision: comilation problems with newer gcc versions. See bugzilla. Possibly switch to cmake?
- [x] media-sound/denemo: improvements with guile-2, no longer support guile-1 in the ebuild, see bugzilla.
- [ ] improve freecad support by adding the missing dependencies
- [x] improve and fix opencascade support in sci-mathematics/netgen
- [x] look into weidu compile failure -> added versioned ebuild, issue is restricted to devel branch, see [this issue](https://github.com/WeiDUorg/weidu/issues/127)
- [ ] dev-python/pyside: need a local ebuild? On [Qt for Python](http://wiki.qt.io/Qt_for_Python/GettingStarted/X11) they say, the same version as Qt is needed. The ebuild from qt overlay uses branch 5.9, but people (including me) might have installed Qt 5.11 already. Also there would be no cross-repo dependency.
- [x] OpenEXR Suite: see [PR](https://github.com/gentoo/gentoo/pull/10030) and [Bug](https://bugs.gentoo.org/639998)
- [x] media-gfx/alembic has 1.7.9 -> see [Bugzilla](https://bugs.gentoo.org/667230) and [PR](https://github.com/gentoo/gentoo/pull/10003)
- [ ] games-util/simulationcraft new version 801-01: check if cmake is working

## Less needed packages not in official trees
- [ ] look through and check whether updates are needed
- [ ] media-gfx/renderman has update to 22
- [ ] media-gfx/renderman-for-blender might have update to 22
- [ ] dev-util/smartgit has 18.1
- [ ] migration from versionator to eapi7-ver for some packages

## Other things to do
- [ ] check possibilities for CI of the repo. Possible use cases: automatic merging of all ebuild, automatic merging after update
