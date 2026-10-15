#requires -Version 5.1
<#
.SYNOPSIS
Download portable Windows build tools and activate them in this PowerShell session.
.DESCRIPTION
Installs pinned tools under .local/windows-tools. Downloads are verified before
extraction; no installer, registry changes or administrator privileges are used.
Run again in each new session to reuse the tools and restore its environment.
#>

& {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'
    Set-StrictMode -Version Latest
    if ($env:OS -ne 'Windows_NT' -or $env:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
        throw 'Use 64-bit PowerShell on Windows x64.'
    }
    $project = Split-Path $PSScriptRoot -Parent
    if ($project -match '\s') {
        throw 'FPC bootstrap Makefiles require a checkout path without spaces.'
    }
    $tools = Join-Path $project '.local/windows-tools'
    $downloads = Join-Path $project '.local/downloads/windows'
    New-Item -ItemType Directory -Force $tools, $downloads | Out-Null
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    function Get-Download([string]$Url, [string]$Sha256) {
        $name = $Url.Substring($Url.LastIndexOf('/') + 1)
        $archive = Join-Path $downloads ($Sha256.Substring(0, 12) + '-' + $name)
        if (-not (Test-Path -LiteralPath $archive)) {
            Write-Host "Downloading $name..."
            $partial = "$archive.partial"
            Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $partial
            if ((Get-FileHash -LiteralPath $partial -Algorithm SHA256).Hash -ne $Sha256) {
                throw "Checksum mismatch: $partial"
            }
            Move-Item -LiteralPath $partial -Destination $archive
        }
        elseif ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $Sha256) {
            throw "Checksum mismatch: $archive. Remove that cached download and rerun setup."
        }
        return $archive
    }

    function Install-Package(
        [string]$Name, [string]$Url, [string]$Sha256, [string[]]$Required,
        [switch]$Inno
    ) {
        $destination = Join-Path $tools $Name
        $stamp = Join-Path $destination '.complete'
        $missing = @($Required | Where-Object {
            -not (Test-Path -LiteralPath (Join-Path $destination $_) -PathType Leaf)
        })
        if ((Test-Path -LiteralPath $stamp) -and
            (Get-Content -LiteralPath $stamp -Raw).Trim() -eq $Sha256 -and
            $missing.Count -eq 0) {
            return $destination
        }
        $archive = Get-Download $Url $Sha256
        # Keep SDK header paths below Windows PowerShell's path length limit.
        $staging = Join-Path $tools ('.stage-' + [Guid]::NewGuid().ToString('N').Substring(0, 12))
        Write-Host "Extracting $Name..."
        try {
            if ($Inno) {
                $log = & $innoextract --silent --output-dir $staging $archive
                if ($LASTEXITCODE -ne 0) { throw "innoextract failed for ${Name}: $log" }
            }
            else {
                [IO.Compression.ZipFile]::ExtractToDirectory($archive, $staging)
            }
            foreach ($file in $Required) {
                if (-not (Test-Path -LiteralPath (Join-Path $staging $file) -PathType Leaf)) {
                    throw "Missing $file in $Name."
                }
            }
            Set-Content -LiteralPath (Join-Path $staging '.complete') -Value $Sha256 -Encoding ASCII
            # Replace only this script's versioned tool directory, after extraction succeeds.
            if (Test-Path -LiteralPath $destination) {
                Remove-Item -LiteralPath $destination -Recurse -Force
            }
            Move-Item -LiteralPath $staging -Destination $destination
        }
        finally {
            if (Test-Path -LiteralPath $staging) {
                Remove-Item -LiteralPath $staging -Recurse -Force
            }
        }
        return $destination
    }

    # Windows PowerShell 5.1 may otherwise negotiate an obsolete TLS version.
    $previousTls = [Net.ServicePointManager]::SecurityProtocol
    try {
        [Net.ServicePointManager]::SecurityProtocol = $previousTls -bor [Net.SecurityProtocolType]::Tls12
        $pythonVersion = '3.13.9'
        $llvmVersion = '20261006'
        $llvmMajor = '23'
        $cmakeVersion = '4.4.4'
        $ninjaVersion = '1.13.2'
        $nasmVersion = '3.01'
        $innoVersion = '1.9'
        $fpcVersion = '3.2.2'
        $pythonRuntime = 'python' + ([version]$pythonVersion).ToString(2).Replace('.', '')
        $llvmRoot = "llvm-mingw-$llvmVersion-ucrt-x86_64"
        $cmakeRoot = "cmake-$cmakeVersion-windows-x86_64"
        $nasmRoot = "nasm-$nasmVersion"

        $python = Install-Package "python-$pythonVersion" `
            "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-embed-amd64.zip" `
            '91d828c2da3a029b41699e918674a0cb379c02cf20dab9c501306885f837402a' `
            @('python.exe', "$pythonRuntime.zip", "$pythonRuntime.dll", '_ssl.pyd', '_lzma.pyd', 'libssl-3.dll', 'libcrypto-3.dll')
        $llvm = Install-Package "llvm-mingw-$llvmVersion" `
            "https://github.com/mstorsjo/llvm-mingw/releases/download/$llvmVersion/$llvmRoot.zip" `
            '317492c456aa27ee607a5919f1d2d38dcdc1112516a24d0bf4b00d078f52d17a' `
            @('bin/clang.exe', "bin/clang-$llvmMajor.exe", 'bin/libclang-cpp.dll',
              "bin/libLLVM-$llvmMajor.dll", 'bin/ld.lld.exe',
              'bin/llvm-ar.exe', 'bin/llvm-ranlib.exe', 'bin/llvm-readobj.exe',
              'bin/i686-w64-mingw32-clang.exe', 'bin/i686-w64-mingw32-clang++.exe',
              'bin/i686-w64-mingw32-windres.exe', 'i686-w64-mingw32/bin/libunwind.dll',
              'bin/x86_64-w64-mingw32-clang.exe', 'bin/x86_64-w64-mingw32-clang++.exe',
              'bin/x86_64-w64-mingw32-windres.exe', 'x86_64-w64-mingw32/bin/libunwind.dll' |
              ForEach-Object { "$llvmRoot/$_" })
        $llvm = Join-Path $llvm $llvmRoot
        $cmake = Install-Package "cmake-$cmakeVersion" `
            "https://github.com/Kitware/CMake/releases/download/v$cmakeVersion/$cmakeRoot.zip" `
            'bace36e94b31c68ab6fa295f26dfa11219e0701cf7c94b0284a7d1cb13dac536' `
            @("$cmakeRoot/bin/cmake.exe")
        $cmake = Join-Path $cmake "$cmakeRoot/bin"
        $ninja = Install-Package "ninja-$ninjaVersion" `
            "https://github.com/ninja-build/ninja/releases/download/v$ninjaVersion/ninja-win.zip" `
            '07fc8261b42b20e71d1720b39068c2e14ffcee6396b76fb7a795fb460b78dc65' `
            @('ninja.exe')
        $nasm = Install-Package $nasmRoot `
            "https://www.nasm.us/pub/nasm/releasebuilds/$nasmVersion/win64/$nasmRoot-win64.zip" `
            'e0ba5157007abc7b1a65118a96657a961ddf55f7e3f632ee035366dfce039ca4' `
            @("$nasmRoot/nasm.exe")
        $nasm = Join-Path $nasm $nasmRoot
        $unpacker = Install-Package "innoextract-$innoVersion" `
            "https://constexpr.org/innoextract/files/innoextract-$innoVersion/innoextract-$innoVersion-windows.zip" `
            '6989342c9b026a00a72a38f23b62a8e6a22cc5de69805cf47d68ac2fec993065' `
            @('innoextract.exe')
        $innoextract = Join-Path $unpacker 'innoextract.exe'
        # The official combined installer supplies GNU Make and its utilities,
        # but its Win64 compiler is hosted on Win32. FPCupdeluxe supplies the
        # native Win64 bootstrap separately; extract the installer without running it.
        $fpc = Install-Package "fpc-$fpcVersion" `
            "https://downloads.freepascal.org/fpc/dist/$fpcVersion/i386-win32/fpc-$fpcVersion.win32.and.win64.exe" `
            '8c255390544b051388b577eb61c6191a04883264afe0e3369b3600a56daf7bde' `
            @('make.exe', 'pwd.exe', 'cp.exe', 'rm.exe', 'mv.exe', 'gecho.exe',
              'gmkdir.exe', 'ginstall.exe', 'diff.exe', 'cmp.exe' |
              ForEach-Object { 'app/bin/i386-win32/' + $_ }) -Inno
        $fpcBin = Join-Path $fpc 'app/bin/i386-win32'
        $bootstrapHash = '47d795f38e669388616bcf45e3fe56f61ed0618d9ee0d46995ace0d49abc5a27'
        $bootstrap = Join-Path $fpcBin 'ppcx64.exe'
        if (-not (Test-Path -LiteralPath $bootstrap) -or
            (Get-FileHash -LiteralPath $bootstrap -Algorithm SHA256).Hash -ne $bootstrapHash) {
            $download = Get-Download `
                "https://github.com/LongDirtyAnimAlf/fpcupdeluxe/releases/download/bootstrappers_v1.0/fpcup-$($fpcVersion.Replace('.', '_'))-x86_64-win64-ppcx64.exe" `
                $bootstrapHash
            Copy-Item -LiteralPath $download -Destination $bootstrap
        }
    }
    finally {
        [Net.ServicePointManager]::SecurityProtocol = $previousTls
    }

    # Embedded Python ignores the script directory and PYTHONPATH. Keep its
    # isolated standard library, adding only this checkout's build modules.
    $pythonPath = "$pythonRuntime.zip`n.`n../../../tools`n"
    [IO.File]::WriteAllText((Join-Path $python "$pythonRuntime._pth"), $pythonPath,
        [Text.UTF8Encoding]::new($false))
    $identity = foreach ($option in '-iV', '-iSP', '-iSO') {
        $value = & $bootstrap $option
        if ($LASTEXITCODE -ne 0) { throw "The FPC bootstrap identity query $option failed." }
        $value
    }
    if (($identity -join ',') -ne "$fpcVersion,x86_64,win64") {
        throw "The FPC bootstrap must be native Win64 FPC $fpcVersion."
    }
    & (Join-Path $python 'python.exe') -c 'import compiler, ssl, lzma, sys; from pathlib import Path; assert compiler.ROOT == Path(sys.argv[1]).resolve()' $project
    if ($LASTEXITCODE -ne 0) { throw 'The portable Python environment is incomplete.' }

    $paths = @($python, (Join-Path $llvm 'bin'), $cmake, $ninja, $nasm, $fpcBin)
    $env:PATH = (@($paths) + @($env:PATH -split ';' | Where-Object { $_ -and $_ -notin $paths })) -join ';'
    $env:LLVM_MINGW = $llvm
    $env:FPC_BOOTSTRAP = $bootstrap
    $env:PYTHONUTF8 = '1'
    Write-Host 'Windows tools ready. Build with: python tools/build.py --release'
}
