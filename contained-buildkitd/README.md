# Working with Contained `buildkitd` in a WCOW

## Running `buildkitd.exe`

1. Copy the `containerd.exe` and `buildkitd.exe` binaries to `dockerfile/bin`
1. `cd dockerfile`
1. Build the image: `docker build -t buildkitd .`
1. Run the container, mounting the `bin` directory 
    (to make it easy to modify without rebuilding the image, which can be time consuming)
    
    **Option 1:** _if running `containerd.exe` on the host instead of container_

    Switchd over to using **Host Process Containers**:

    ```powershell
    nerdctl.exe run -it --entrypoint powershell --isolation host `
        -v C:\play\buildkit-on-windows\contained-buildkitd\bin\:C:\bin `
        profnandaa/buildkitd
    ```

1. You should see something similar to:
    ![image](https://github.com/profnandaa/buildkit-on-windows/assets/261265/435d28c2-9883-4a5d-981b-2d093b39fe44)

## Running `buildctl.exe` on the host

1. Check all is good, run: `buildctl debug info`
    ```
    BuildKit: github.com/moby/buildkit v0.0.0+unknown
    ```

## Known Issues

Option 1 (HPC):

```
PS C:\play\dockerfiles\samp1> buildctl build `
>> --output type=image,name=docker.nandaa.dev/samp1,push=false `
>> --frontend=dockerfile.v0 `
>> --local context=. --local dockerfile=. --no-cache
[+] Building 0.2s (1/1) FINISHED
 => ERROR [internal] load build definition from Dockerfile                                                                              0.0s
------
 > [internal] load build definition from Dockerfile:
------
error: failed to solve: failed to read dockerfile: failed to mount {windows-layer C:\ProgramData\containerd\root\io.containerd.snapshotter.v1.windows\snapshots\169  [rw]}: failed to set volume mount path for layer C:\ProgramData\containerd\root\io.containerd.snapshotter.v1.windows\snapshots\169: failed to bind target "C:\\ProgramData\\containerd\\root\\io.containerd.snapshotter.v1.windows\\snapshots\\169\\Files" to root "C:\\Users\\ADMINI~1\\AppData\\Local\\Temp\\2\\buildkit-mount1351057556": Access is denied.: failed to set volume mount path for layer C:\ProgramData\containerd\root\io.containerd.snapshotter.v1.windows\snapshots\169: failed to bind target "C:\\ProgramData\\containerd\\root\\io.containerd.snapshotter.v1.windows\\snapshots\\169\\Files" to root "C:\\Users\\ADMINI~1\\AppData\\Local\\Temp\\2\\buildkit-mount1351057556": Access is denied.
```