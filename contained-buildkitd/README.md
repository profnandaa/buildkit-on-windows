# Working with Contained `buildkitd` in a WCOW

## Running `buildkitd.exe`

1. Copy the `containerd.exe` and `buildkitd.exe` binaries to `dockerfile/bin`
1. `cd dockerfile`
1. Build the image: `docker build -t buildkitd .`
1. Run the container, mounting the `bin` directory 
    (to make it easy to modify without rebuilding the image, which can be time consuming)
    
    **Option 1:** _if running `containerd.exe` on the host instead of container_
    ```powershell
    docker run `
    -v C:\<absolute-path>\bin:C:\bin `
    -v //./pipe/buildkitd://./pipe/buildkitd `
    -v //./pipe/containerd-containerd://./pipe/containerd-containerd `
    -v //./pipe/containerd-containerd.ttrpc://./pipe/containerd-containerd.ttrpc `
    -it buildkitd powershell
    ```

    **Option 2:** _if running both `containerd.exe` and `buildkitd.exe` in the same container_

    ```powershell
    docker run `
    -v C:\<absolute-path>\bin:C:\bin `
    -v //./pipe/buildkitd://./pipe/buildkitd `
    -it buildkitd powershell
    ```

1. You should see something similar to:
    ![image](https://github.com/profnandaa/buildkit-on-windows/assets/261265/435d28c2-9883-4a5d-981b-2d093b39fe44)

## Running `buildctl.exe` on the host

1. Check all is good, run: `buildctl debug info`
    ```
    BuildKit: github.com/moby/buildkit v0.0.0+unknown
    ```

## Known Issues

The experiment goes on. So far the daemon can run in the container but we have some missing dependencies:

```
PS C:\play\dockerfiles\samp1> buildctl build `
>> --output type=image,name=docker.nandaa.dev/samp1,push=false `
>> --frontend=dockerfile.v0 `
>> --local context=. --local dockerfile=.
[+] Building 0.3s (1/1) FINISHED
 => ERROR [internal] load build definition from Dockerfile                                                                              0.2s
------
 > [internal] load build definition from Dockerfile:
------
error: failed to solve: failed to read dockerfile: failed to mount {windows-layer C:\ProgramData\containerd\root\io.containerd.snapshotter.v1.windows\snapshots\1  [rw]}: failed to activate layer C:\ProgramData\containerd\root\io.containerd.snapshotter.v1.windows\snapshots\1: hcsshim::ActivateLayer failed in Win32: The specified module could not be found. (0x7e): failed to activate layer C:\ProgramData\containerd\root\io.containerd.snapshotter.v1.windows\snapshots\1: hcsshim::ActivateLayer failed in Win32: The specified module could not be found. (0x7e)
```

`buildkitd` stacktrace:

```
failed to read dockerfile: failed to mount {windows-layer C:\ProgramData\containerd\root\io.containerd.snapshotter.v1.windows\snapshots\1  [rw]}: failed to activate layer C:\ProgramData\containerd\root\io.containerd.snapshotter.v1.windows\snapshots\1: hcsshim::ActivateLayer failed in Win32: The specified module could not be found. (0x7e): failed to activate layer C:\ProgramData\containerd\root\io.containerd.snapshotter.v1.windows\snapshots\1: hcsshim::ActivateLayer failed in Win32: The specified module could not be found. (0x7e)
9976 v0.0.0+unknown C:\bin\buildkitd.exe --debug --containerd-worker=true
github.com/moby/buildkit/snapshot.(*localMounter).Mount
        C:/buildkit/snapshot/localmounter_windows.go:53
github.com/moby/buildkit/source/local.(*localSourceHandler).snapshot
        C:/buildkit/source/local/source.go:222
github.com/moby/buildkit/source/local.(*localSourceHandler).Snapshot
        C:/buildkit/source/local/source.go:153
github.com/moby/buildkit/solver/llbsolver/ops.(*SourceOp).Exec
        C:/buildkit/solver/llbsolver/ops/source.go:108
github.com/moby/buildkit/solver.(*sharedOp).Exec.func2
        C:/buildkit/solver/jobs.go:931
github.com/moby/buildkit/util/flightcontrol.(*call[...]).run
        C:/buildkit/util/flightcontrol/flightcontrol.go:121
sync.(*Once).doSlow
        C:/Program Files/Go/src/sync/once.go:74
sync.(*Once).Do
        C:/Program Files/Go/src/sync/once.go:65
runtime.goexit
        C:/Program Files/Go/src/runtime/asm_amd64.s:1650
```