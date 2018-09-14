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

## Packages which need updating

- [ ] dev-libs/tvision: comilation problems with newer gcc versions. See bugzilla. Possibly switch to cmake?
- [ ] media-sound/denemo: improvements with guile-2, no longer support guile-1 in the ebuild, see bugzilla.

## Less needed packages not in official trees
- [ ] look through and check whether updates are needed
- [ ] improve freecad support by adding the missing dependencies
