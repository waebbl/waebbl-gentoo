## Packages to check and possibly include

- [x] [sci-libs/mumps](http://mumps.enseeiht.fr) availabe in science overlay in outdated version, needs manual download? Has been included in official tree and updated to current release. Ebuild Depends on old scotch-5.1 and does not support current scotch-6 -> https://github.com/gentoo/gentoo/pull/10378
- [ ] [sci-misc/elmer](https://github.com/ElmerCSC/elmerfem) available in science overlay in outdated version as meta and subpackages. Possibly only need one package with latest version
- [ ] [net-im/quaternion](https://github.com/QMatrixClient/Quaternion) new package: Qt5 client for matrix protocol
- [ ] [sci-mathematics/salome-meta](https://salome-platform.org/) new package: probably use salome-platform as package name without the need for meta and subpackages. Tool for numerical simulation. Currently the subpackage sci-libs/libmed is available
- [ ] [media-libs/smesh](https://salome-platform.org/) new package: possibly make separate smesh package from salome platform first, for use in freecad, see also https://github.com/LaughlinResearch/SMESH
- [ ] [sci-mathematics/ngsolve](https://github.com/NGSolve/ngsolve) new package: FEM tools tied to sci-libs/netgen
- [ ] [sci-visualization/knossos](https://github.com/knossos-project/knossos) new package: visualization and annotation of 3D image data.
- [x] [app-arch/zipios](https://github.com/Zipios/Zipios) new package: used by freecad, currently internal package is used.
- [ ] [media-gfx/makehuman](https://github.com/makehumancommunity/makehuman) new package: take a look at cg overlay, if their ebuild is usable
- [ ] [media-gfx/solvespace](https://github.com/solvespace/solvespace) new package: parametric 2D/3D CAD package
- [ ] [sci-libs/gmsh](https://gitlab.onelab.info/gmsh/gmsh) available in science overlay with an outdated version (current: 4.0.2)
- [ ] [media-gfx/tetwild](https://github.com/Yixin-Hu/TetWild): new package (additional deps needed: pymesh, pyrenderer, CLI11, see his README.md for details)
- [ ] [sci-visualization/vistrails](https://github.com/VisTrails/VisTrails): new package (b.g.o has ebuild for 1.4 / 1.5)
- [ ] [sci-libs/vxl](https://github.com/vxl/vxl): available as live ebuild in science overlay
- [ ] [dev-python/pythonocc](https://github.com/tpaviot) new package: python bindings for OpenCASCADE, several repos
- [ ] [sci-visualization/ifcopenshell](https://github.com/IfcOpenShell/IfcOpenShell) new package: importer, converter and viewer for IFC files used in architecture
- [ ] [sci-visualization/analysis-situs](https://gitlab.com/ssv/AnalysisSitus) new package: [Homepage](http://analysissitus.org) analyzing models in B-REP representation using the OpenCASCADE kernel -> currently windows only
- [x] [media-gfx/luxcorerender](https://github.com/LuxCoreRender/LuxCore) new package: supported by freecad. -> initial commit done
- [x] [media-libs/opencamlib](https://github.com/aewallin/opencamlib) new package: supported by freecad.
- [ ] [sci-mathematics/fenics](https://bitbucket.org/fenics-project) new package: supported by freecad.
- [ ] [media-gfx/odafileconverter](https://www.opendesign.com/guestfiles/oda_file_converter) new package: for DWG file import/export support in freecad (binary package)
- [ ] [media-gfx/shipcad](https://github.com/gpgreen/ShipCAD): new package: CAD software for ship construction
- [ ] [media-gfx/meshroom](https://github.com/alicevision/meshroom): new package: 3D reconstruction software
- [ ] [media-libs/alicevision](https://github.com/alicevision/AliceVision): new package: photogrammetric computer vision framework, needed by meshroom
- [ ] [sci-libs/siconos](https://github.com/siconos/siconos): new package: simulation framework for nonsmooth dynamical systems
- [ ] [sci-libs/chrono](https://github.com/projectchrono/chrono): new package: C++ library for multi-physics simulation


## Packages with bugs assigned

- [ ] media-gfx/alembic-1.7.9: see https://bugs.gentoo.org/667728
- [x] [dev-util/codespell](https://github.com/codespell-project/codespell) new package: tool to check spelling in code files, see [Bug](https://bugs.gentoo.org/667830)
- [ ] dev-libs/tvision: comilation problems with newer gcc versions. See bugzilla. Possibly switch to cmake?
- [x] media-sound/denemo: improvements with guile-2, no longer support guile-1 in the ebuild, see bugzilla. -> merded
- [x] OpenEXR Suite: see [PR](https://github.com/gentoo/gentoo/pull/10030) and [Bug](https://bugs.gentoo.org/639998) -> merged


## Packages which need updating

- [ ] improve freecad support by adding the missing dependencies
- [x] dev-python/pyside: need a local ebuild? On [Qt for Python](http://wiki.qt.io/Qt_for_Python/GettingStarted/X11) they say, the same version as Qt is needed. The ebuild from qt overlay uses branch 5.9, but people (including me) might have installed Qt 5.11 already. Also there would be no cross-repo dependency -> https://github.com/gentoo/gentoo/pull/10085
- [ ] games-util/simulationcraft new version 801-01: check if cmake is working


## Less needed packages not in official trees

- [ ] look through and check whether updates are needed
- [x] media-gfx/renderman has update to 22
- [ ] media-gfx/renderman-for-blender might have update to 22
- [x] dev-util/smartgit has 18.1
- [x] migration from versionator to eapi7-ver for some packages


## Other things to do

- [ ] check possibilities for CI of the repo. Possible use cases: automatic merging of all ebuild, automatic merging after update
- [ ] start updating ebuilds to EAPI 7
- [ ] [sci-libs/trilinos](https://github.com/trilinos/Trilinos) available in science overlay in current version. Fetch is currently not working, using the github sources it doesn't compile (patching, configuration and compile errors). Also the set of use-flags is somewhat counterintuitive, in that it states various gentoo packages to use. Trilinos itself has a high level abstraction of internal packages to build. Using them as use flags, would IMO make more sense.

