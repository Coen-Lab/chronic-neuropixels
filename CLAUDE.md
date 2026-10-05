# chronic-neuropixels

Parametric CAD parts (Autodesk Inventor `.ipt`) for a 3D-printable chronic Neuropixels implant (payload and docking modules, holders, constructor), plus community-contributed variant parts and MATLAB code that reproduces the paper figures. There is no build system, package manager, test suite or CI; the "source" is the CAD files and Markdown docs.

## Layout

| Path | Holds | Go here for |
| --- | --- | --- |
| `NP1/`, `NP2/`, `NP2-Alpha/` | Five parts per probe version: `<Ver>_Payload`, `_PayloadHolder`, `_PayloadLid`, `_Docking`, `_DockingHolder` (`.ipt`) | Changing a core implant part for one probe type |
| `Universal/` | `Universal_ConstructorHead.ipt`, `Universal_ProbeSharpener.ipt` | Parts shared by all probe versions |
| `XtraModifications/` | Community variants, one subfolder per use case (`Mouse_FreelyMoving/`), editable CAD plus STEP/STP exports and preview PNGs | Adding or editing a contributed part |
| `XtraModifications/README.md` | Contribution rules (folder choice, naming, README entry) | Before adding a part |
| `XtraModifications/Mouse_FreelyMoving/README.md` | One `##` section per part or part group: function, material, software used, contact | Documenting a contributed part |
| `Paper-figures/` | MATLAB: `figuresForPaper.m` (entry point), `plot*.m`, `getRMSAndAmp.m`, `saveDataForPaper.m`, `bombcell/` (vendored parameter helpers `bc_*.m`) | Figure code only; unrelated to the CAD |
| `README.md` | Parts list, per-part print notes, screws and inserts, assembly steps, changelog notes | User-facing documentation for the core parts |
| `.gitignore` | `*.stl`, `*.stp`, `*.ipj`, `*OldVersions`, `*Assemblies` | See traps below |

Untracked local-only items that may exist in a checkout: `XAssemblies/` (assemblies `.iam`, images, `MinorParts`, `OldVersions`), `NP2/OldVersions`, and `ChronicNeuropixels.ipj` (Inventor project file). They are ignored by `.gitignore`; do not expect them on a fresh clone and do not add them.

## Build, run, test

There are no commands to build, test or deploy. Parts are edited in Autodesk Inventor 2023 or later and exported (STL/STEP) by hand for printing. Figure code is run from a MATLAB session by calling `figuresForPaper` in `Paper-figures/`; it needs external data (see `Paper-figures/README.md`).

## Conventions

- Core part names follow `<ProbeVersion>_<Function>.ipt` (`NP1`, `NP2`, `NP2-Alpha`, `Universal`). Community parts follow `ProbeType_Function`, one file per part, and live under `XtraModifications/<AnimalState>/` (for example `Mouse_FreelyMoving`).
- Parameters are driven by Inventor parameter tables inside each `.ipt`; edit parameters rather than geometry. Notable ones: `REDUCEDHOLDERVERSION` (0 = construction holder, 1 = reduced holder) in the `PayloadHolder` files.
- Files are cross-linked: Payload parameters drive Docking and DockingHolder. A parameter change in one `.ipt` can move others, so open the linked parts after editing Payload.
- Prefer editable formats for contributed parts; add STEP/STP only when no free editable format exists.
- Every contributed part needs a README section whose heading matches the file name, with description, one or two images, print material, software used and contact; list it in the index at the top of that README.
- Layout across NP1/NP2/NP2-Alpha is parallel: a change to a core part usually needs the equivalent edit in the other two probe folders.

## Traps

- `.gitignore` ignores `*.stp` and `*.stl`, yet several `.stp` files in `XtraModifications/Mouse_FreelyMoving/` are tracked. A new `.stp` or `.stl` needs `git add -f`; otherwise it is silently skipped. `*Assemblies` also hides any new directory or file ending in `Assemblies`.
- `.ipt` and `.iam` files are binary: no diffs or merges. Do not open and re-save them casually, and never hand-edit them as text.
- Inventor 2023 is the minimum version. Some contributed parts were saved in 2024 or 2025 and are not backwards compatible (stated in the contributed README).
- A 2024 parameter change altered Payload wall and lid behaviour for inter-probe distances between 2 and 4 mm; the root `README.md` Issues section explains it. Check it before touching those parameters.
- File names with spaces exist (`..._fin v2.ipt`); quote paths in shell commands.
- `Paper-figures/saveDataForPaper.m` is reference only and will not run elsewhere. `figuresForPaper.m` loads data from a hard-coded network share path and is not runnable without editing `saveDir`. Fig. 5 tracking code is not in this repo.
- `Paper-figures/bombcell/` is a small vendored subset of an external toolbox; do not expand or restyle it.
- README images are hosted on GitHub asset URLs, not in the repo (except `NP1_Duan_SummaryPic-1.png`, which the contributed README links by relative path). Keep that relative link in sync if the PNG moves.

## Deeper docs

- `README.md`: parts list with print material per part, hardware (screws, inserts), assembly steps 1 to 4, license.
- `XtraModifications/README.md`: contribution checklist.
- `XtraModifications/Mouse_FreelyMoving/README.md`: per-variant function, materials, software.
- `Paper-figures/README.md`: how to replicate figures and where the dataset lives.
