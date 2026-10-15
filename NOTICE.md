# Attribution

This unofficial port is based on the reconstructed Delphi source for
**Space Rangers HD: A War Apart**.
It is not affiliated with the game's developers or publisher.

- Game developers: SNK Games, Elemental Games, and Katauri Interactive.
- Publisher: Fulqrum Publishing.
- Original game notices: © 2013 Fulqrum Publishing Ltd.; © 2024 СНК-Games.
- Decompilation: [SpaceRangersHD_decomp](https://github.com/pakompom/SpaceRangersHD_decomp).
- Utility Functions Pack compatibility: KIaxons' [Utility-Functions-Pack](https://github.com/KIaxons/Utility-Functions-Pack),
  version 2.2.1, reference revision `b24d0fd`. The native Pascal implementation
  follows the reference source and the distributed DLL's script interface.
- AutoSearch compatibility: ExpAutoSearch by uhanich, 100kg, and Klaxons.
  The native Pascal implementation follows the distributed AutoSearch.dll's
  behavior and script interface.
- Software renderer: [OKGF](https://github.com/pakompom/okgf), under its
  [MIT license](vendor/okgf/LICENSE); bundled SoftFloat has its own
  [BSD 3-Clause license](vendor/okgf/vendor/softfloat/COPYING.txt).
- Windowing, input, and audio device: [SDL](https://libsdl.org/), under its zlib license.
- Ogg/Vorbis audio decoding: [Xiph.Org libraries](https://xiph.org/), under BSD-style licenses.
- AVI video decoding: [Xvid](https://www.xvid.com/), under the GNU GPL.
- Gamepad-to-keyboard/mouse mapping in the Anbernic stock-firmware package:
  [gptokeyb](https://github.com/PortsMaster/gptokeyb), a separate program under
  the [GNU GPL 2.0](vendor/gptokeyb/LICENSE.md); its source ships in the package.
- Compiler and runtime: [Free Pascal](https://www.freepascal.org/), with
  [source and license details](vendor/fpc/PORT.md).
- Selected fixes adapted from
  [giantplaceholder/spacerangershd-fpc-fixes](https://github.com/giantplaceholder/spacerangershd-fpc-fixes),
  under its [MIT license](licenses/spacerangershd-fpc-fixes.txt).

The recovered game and third-party sources retain their original terms; they
are not covered by this project’s MIT license. Third-party source retains its
original notices and terms. Free Pascal and image libraries remain subject to
their respective licenses.

Custom additions and modifications made for this FPC port are licensed under
the [MIT license](LICENSE). The underlying game decompilation retains its
existing terms.
