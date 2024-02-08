# Working with Contained `buildkitd` in a WCOW

## Running `buildkitd.exe`

1. Copy the `containerd.exe` and `buildkitd.exe` binaries to `dockerfile/bin`
1. `cd dockerfile`
1. Build the image: `docker build -t buildkitd .`
1. Run the container, mounting the start script directory (to make it easy to modify without rebuilding)
    - `docker run --name buildkitd -v C:\<absolute-path>\start:C:\start -it buildkitd powershell`
1. You should see something similar to:
    ![image](https://github.com/profnandaa/buildkit-on-windows/assets/261265/435d28c2-9883-4a5d-981b-2d093b39fe44)

## Running `buildctl.exe` on the host

1. Expose the environment variable for linking to the container:
    - on PS, run: `$env:BUILDKIT_HOST="docker-container://buildkitd"`
1. Check all is good: `buildctl debug info`

    > So far, I'm getting this error: `error: failed to call info: Unavailable: connection error: desc = "error reading server preface: http2: frame too large"`
    >
    > Investigating! Check back.
