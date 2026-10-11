#!/usr/bin/env python3
"""Compare immutable render_throughput executables and their framebuffer hashes."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--arch', choices=['armhf', 'aarch64'], required=True)
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--optimized', type=Path, required=True)
    parser.add_argument('--library-dir', type=Path, required=True,
                        help='Immutable copy of the linked game libraries.')
    parser.add_argument('--sdk-root', type=Path, required=True)
    parser.add_argument('--qemu', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    triple = 'arm-linux-gnueabihf' if args.arch == 'armhf' else 'aarch64-linux-gnu'
    sub = 'armhf' if args.arch == 'armhf' else 'arm64'
    sdk = args.sdk_root.resolve() / sub / 'root'
    binaries = {'baseline': args.baseline.resolve(), 'optimized': args.optimized.resolve()}
    hashes = {k: hashlib.sha256(v.read_bytes()).hexdigest() for k, v in binaries.items()}
    original_affinity = os.sched_getaffinity(0)
    runs = {'baseline': [], 'optimized': []}
    try:
        os.sched_setaffinity(0, {min(original_affinity)})
        for label in ['baseline', 'optimized', 'optimized', 'baseline']:
            command = [str(args.qemu.resolve()), '-L', str(sdk), '-E',
                       f'LD_LIBRARY_PATH={args.library_dir.resolve()}:{sdk}/usr/lib:'
                       f'{sdk}/usr/lib/{triple}:{sdk}/lib/{triple}',
                       '-E', 'SDL_VIDEODRIVER=dummy', '-E', 'SDL_AUDIODRIVER=dummy',
                       str(binaries[label])]
            process = subprocess.run(command, capture_output=True, text=True, timeout=300)
            if process.returncode:
                raise RuntimeError(f'{label} exited {process.returncode}: {process.stderr}')
            rows = [json.loads(line) for line in process.stdout.splitlines() if line.startswith('{')]
            assert len(rows) == 4, process.stdout
            runs[label].append(rows)
            print(label, [(r['case'], r['median_ms']) for r in rows], flush=True)
    finally:
        os.sched_setaffinity(0, original_affinity)
    comparison = []
    for i in range(4):
        rows = [run[i] for group in runs.values() for run in group]
        assert len({row['case'] for row in rows}) == 1
        assert len({row['hash'] for row in rows}) == 1, rows
        before = statistics.median(run[i]['median_ms'] for run in runs['baseline'])
        after = statistics.median(run[i]['median_ms'] for run in runs['optimized'])
        comparison.append({'case': rows[0]['case'], 'baseline_ms': before,
                           'optimized_ms': after, 'time_reduction_percent': round((1-after/before)*100, 2),
                           'throughput_increase_percent': round((before/after-1)*100, 2),
                           'framebuffer_hash': rows[0]['hash']})
    for label, path in binaries.items():
        assert hashlib.sha256(path.read_bytes()).hexdigest() == hashes[label], 'Executable changed during measurement'
    report = {'arch': args.arch, 'environment': 'QEMU, SDL dummy/software, single host CPU affinity',
              'method': 'ABBA; seven samples per run; median of two run medians; 2048 draws per scene',
              'physical_hardware_tested': False, 'game_fps_measured': False,
              'fixture_sha256': hashes, 'runs': runs, 'comparison': comparison}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(comparison), flush=True)


if __name__ == '__main__':
    main()
