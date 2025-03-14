# Basic Perf Benchmarks

We have created a a PowerShell script to compare build times between
_classic docker build_ and _buildkit_, given a specific dockerfile.

### Usage

You can run the whole test suite in `./dockerfiles/*` with:

```powershell
.\run.ps1
```

You can also run a specific test suite by providing the name of the
subdirectory in `./dockerfiles` e.g

```powershell
.\run.ps1 4
```

You can also supply an arbiterary directory that has a Dockerfile, e.g.

```powershell
.\run.ps1 -Path C:\sample\dockerfile
```

You can also have a list of dockerfiles in sub-directories, where
each dockerfile is in its own sub-directory, e.g.

```powershell
.\run.ps1 -DockerfilesDir C:\sample\dockerfiles
```
