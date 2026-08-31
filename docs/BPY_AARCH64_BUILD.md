# bpy pro linux-aarch64 (GB10) ze zdrojů

Recept z 2026-08-31/09-01. Vznikl proto, že `ComfyUI-UniRig` (rig krok fantasy
characters) potřebuje `import bpy`, a **žádné hotové kolo pro aarch64
neexistuje** — ověřeno jak `pip index versions bpy`, tak cíleným stažením pro
`manylinux2014_aarch64`; conda-forge `bpy` nemá vůbec a kanál `pozzettiandrea`
jen pro `linux-64`.

**Blender navíc pro Linux ARM64 nedodává předkompilované knihovny.** `make
update` architekturu detekuje jako `arm64`, ale pak přeskočí všechny čtyři
sady, které v repozitáři jsou (`linux_x64`, `macos_arm64`, `windows_x64`,
`windows_arm64`). Neexistuje tedy varianta „stáhnout libs a slinkovat" — musí
se přes `make deps`, tedy build 117 závislostí ze zdrojů.

Celý postup proběhl **bez roota**. Trvalo to ~8 hodin, z toho ~1,5 h čistého
kompilování; zbytek bylo 19 pádů a jejich diagnostika.

## Výsledek

    ~/Code/build_linux_bpy/bin/bpy/        Blender 5.1.1, Python 3.13
    ~/Code/blender-src/lib/linux_arm64/    54 sklizených knihoven

Ověřeno: `bpy.app.version_string == "5.1.1"`, vytvoření meshe, armatury
(`type == "ARMATURE"`) a dostupnost `bpy.ops.export_scene.fbx`.

## Volba verze

| Blender | bundlovaný Python |
|---|---|
| v4.5.13 LTS | 3.11.15 |
| v5.0.1 | 3.11.13 |
| **v5.1.1** | **3.13.9** |

Zvoleno v5.1.1 — je to verze, pro kterou má kanál `pozzettiandrea` x86 balíček
`bpy-5.1.1`, takže proti ní je node vyvíjený. Pozor: pixi env nodu chce 3.12,
musí se posunout na 3.13.

## 1. Nástroje bez roota

Pip do vlastního venv (`~/Code/blender-build-venv`), symlinky v
`~/Code/blender-build-bin`: **meson**, **patchelf**.

> `cmake` z pipu (4.x) **nepoužívat** — CMake 4 zahodil kompatibilitu s projekty
> deklarujícími minimum pod 3.5 a mezi 117 závislostmi jich takových je.
> Systémový 3.28 stačí.

> `ninja` z pipu **nepoužívat** — kitware varianta s `jobserver-pipe` hlásí pod
> `make` chybu `Could not initialize jobserver: Invalid file descriptors`.

Ze zdrojů do `~/.local` (`./configure --prefix=$HOME/.local && make && make install`):

| Balíček | Proč |
|---|---|
| libtool 2.4.7 | `check_software.cmake` vyžaduje `libtoolize` |
| yasm 1.3.0 | tamtéž (na ARM se nepoužije, kontrola je plošná) |
| gettext 0.22.5 | `autopoint`, jinak padá `external_flex` |
| ninja 1.12.1 | viz výše |
| texinfo 7.1 | `makeinfo` pro dokumentaci flexu |
| help2man 1.49.3 | tamtéž |
| libICE 1.1.1, libSM 1.2.4, libXt 1.3.0 | MaterialXRenderGlsl chce Xt |

## 2. Prostředí

```bash
export LC_ALL=C.UTF-8 LANG=C.UTF-8        # jinak CMake nerozbalí flac tarball
export ACLOCAL_PATH=$HOME/.local/share/aclocal
export PATH=$HOME/.local/bin:$HOME/Code/blender-build-bin:$PATH
export PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig:\
$HOME/.local/lib/aarch64-linux-gnu/pkgconfig:$HOME/.local/share/pkgconfig
```

`LC_ALL` není kosmetika: bez UTF-8 locale skončí rozbalení `flac-1.4.2.tar.xz`
na `Pathname can't be converted from UTF-8 to current locale`.

## 3. Záplaty v build stromu Blenderu

Originály zůstaly vedle jako `*.orig`. Žádná se netýká geometrie ani armatur —
všechny vypínají render/GUI/audio větve, které headless `bpy` nepoužije.

| Soubor | Zásah | Bez toho |
|---|---|---|
| `cmake/openal.cmake` | `ALSOFT_*` backendy OFF | chce PulseAudio/ALSA `-dev` |
| `cmake/osl.cmake` | `if(FALSE)` na OptiX bloku | clang nenajde `texture_fetch_functions.h` |
| `cmake/libglu.cmake` | `autoreconf -fi` před configure | libtool 2.4.6 vs 2.4.7 mismatch |
| `CMakeLists.txt` | vypnutá `mesa.cmake` | chce `xcb-randr` a řetěz xcb |
| `CMakeLists.txt` | vypnutý `wayland_weston.cmake` | chce `xkbcommon` |
| `cmake/wayland_protocols.cmake` | + multiarch pkgconfig cesta | **viz níže** |
| `cmake/vulkan.cmake` | `lib64` → `lib/aarch64-linux-gnu` | tamtéž |
| `cmake/wayland.cmake` | harvest z multiarch cesty | tamtéž |
| `CMakeLists.txt` (kořen) | GCC check 14.0.0 → 13.0.0 | GCC 13.3 přeložil bez chyby |

### Skutečná aarch64 chyba: `lib64` vs. multiarch

Blender předpokládá, že meson instaluje do `lib64/pkgconfig`. Na x86_64 to
sedí, na Debianu/aarch64 se instaluje do `lib/<triplet>/pkgconfig`. Proto se
nenajde `wayland-scanner.pc` — a to i když si Blender **vlastní wayland staví
sám**. Tohle je jediná kategorie záplat, která je opravdu bug, ne vypnutá
funkce.

### Co nedělat

`MATERIALX_BUILD_RENDER=OFF` **problém neřeší, jen posune** — USD z něj
potřebuje `MaterialXRender/Util.h` a spadne o závislost dál. Správně je doplnit
libXt/libSM/libICE a renderer nechat zapnutý.

## 4. Build

```bash
cd ~/Code/blender-src
make deps                                  # ~1 h čistého času, 117 závislostí
make bpy BUILD_CMAKE_ARGS="\
  -DLIBDIR=$HOME/Code/blender-src/lib/linux_arm64 \
  -DWITH_CYCLES_OSL=OFF -DWITH_HEADLESS=ON -DWITH_XR_OPENXR=OFF"
```

`-DLIBDIR` je povinné: Blender uznává `lib/linux_arm64` jen když v něm najde
`.git` (čeká submodul, ne výstup `make deps`), jinak tiše sáhne po systémových
knihovnách a spadne na chybějícím Epoxy.

`WITH_CYCLES_OSL=OFF` musí odpovídat záplatě v `osl.cmake`.
`WITH_HEADLESS=ON` samo vypne GHOST Wayland i X11.
