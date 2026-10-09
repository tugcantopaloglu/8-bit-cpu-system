import argparse
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


def run(command, cwd):
    result = subprocess.run(command, cwd=cwd, text=True, capture_output=True, timeout=60)
    print(result.stdout, end="")
    print(result.stderr, end="")
    if result.returncode:
        raise RuntimeError(f"Command failed with status {result.returncode}: {command[0]}")
    return result.stdout


def main():
    parser = argparse.ArgumentParser(description="Compile and simulate both maintained CPU source sets")
    parser.add_argument("--iverilog", default="iverilog")
    parser.add_argument("--vvp", default="vvp")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    canonical = repo / "Only Source Codes"
    vivado = repo / "Vivado Files/final_project/final_project.srcs"
    for path in canonical.glob("*.sv"):
        folder = "sim_1/new" if path.name == "cpu.sv" else "sources_1/new"
        if path.read_bytes() != (vivado / folder / path.name).read_bytes():
            raise RuntimeError(f"Maintained source copies differ: {path.name}")
    if (canonical / "memfile.dat").read_bytes() != (vivado / "sources_1/new/memfile.dat").read_bytes():
        raise RuntimeError("Maintained instruction fixtures differ")

    source_sets = {
        "standalone": sorted(canonical.glob("*.sv")),
        "vivado": sorted((vivado / "sources_1/new").glob("*.sv"))
        + [vivado / "sim_1/new/cpu.sv"],
    }
    for name, sources in source_sets.items():
        with tempfile.TemporaryDirectory(prefix=f"cpu-{name}-") as temporary:
            working = Path(temporary)
            shutil.copyfile(canonical / "memfile.dat", working / "memfile.dat")
            for top, extra in (("cpu", []), ("regression", [repo / "tests/regression.sv"])):
                print(f"Compiling and simulating {name}: {top}", flush=True)
                output = working / f"{top}.vvp"
                run([args.iverilog, "-g2012", "-Wall", "-s", top, "-o", str(output)]
                    + [str(path) for path in sources + extra], working)
                stdout = run([args.vvp, str(output)], working)
                if "PASS:" not in stdout:
                    raise RuntimeError(f"No passing assertion result for {name}: {top}")
                if top == "cpu":
                    actual = (working / "result.dat").read_text()
                    expected = (canonical / "result.dat").read_text()
                    if actual != expected:
                        raise RuntimeError("Sample result.dat does not match the tracked output")
                    registers = re.findall(r"reg\[\d\] = ([01]{8})", actual)
                    if [int(value, 2) for value in registers] != [30, 30, 60, 0, 0, 0, 0, 0]:
                        raise RuntimeError("Sample result.dat contains unexpected registers")
    print("PASS: both maintained source sets and tracked sample output")


if __name__ == "__main__":
    main()
