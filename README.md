# Run Nvidia-enabled Linux desktops in Azure
Engineering simulation software uses powerful display graphics and the GPU for a quick rendering of the display. Since virtual linux servers with non display attached secondary graphics as [Nvidia Tesla](https://en.wikipedia.org/wiki/Nvidia_Tesla) does not use GPU direkt rendering by default Xserver configurations. This issue can be easily corrected by modifying configurations on the host computer to allow the use of GPU rendering during a Remote Desktop session.

## Remote visualization
 However, running (and debugging) engineering software and other graphics-heavy software in a remote desktop environment can be challenging for the principal reason that Azure's Nvidia Tesla enabled Linux machines does not use GPU direkt rendering by default Xserver configurations. Starting up the graphics-heavy software can generate errors as the software attempts to initialize DirectX or OpenGL GPU display drivers on the host computer.

Although they lack video outputs, when properly configured, [Azure NV Instances](https://docs.microsoft.com/en-us/azure/virtual-machines/nv-series) eqipped with Tesla GPUs are fully capable of supporting the same graphics APIs and visualization capabilities as their GeForce and Quadro siblings. Below is a collection of the basic requirements to enable graphics on Tesla GPUs, and steps for accomplishing this in the most common cases. My examples below assume a conventional Linux-based x86 compute node like Ubuntu, but they would likely be applicable to other node architectures.

### Enable the windowing system for full use of graphics APIs

Once the GPU operation mode is properly set, the next requirement for full graphics operation is a running a windowing system. At present, the graphics software stack supporting OpenGL and related APIs depends on initialization and context creation facilities provided in cooperation with a running windowing system. A full windowing system is needed when supporting remote visualization software such as simulations software like VMD, VNC, or Virtual GL. Currently, a windowing system is also required for large scale parallel HPC visualization workloads, even though off-screen rendering (e.g. OpenGL FBOs or GLX Pbuffer rendering) is typically used exclusively.

It is desirable to prevent the X Window System X11 server and related utilities from looking for attached displays when using Tesla GPUs. The `UseDisplayDevice` configuration option in `xorg.conf` can be set to `none`, thereby preventing any attempts to detect display, validate display modes, etc. The `nvidia-xconfig` utility can be told to set the display device to none by passing it the command line flag `--use-display-device=none` when you run it to update or generate an `xorg.conf` file.

One of the side effects of enabling a windowing system to support full use of OpenGL and other graphics APIs is that it generally also enables a watchdog timer that will terminate CUDA kernels that run for more than a few seconds. This behavior differs from the compute-only scenario where a Tesla GPU is not graphics-enabled, and will allow arbitrarily long-running CUDA kernels. For HPC workloads, it is usually desirable to eliminate such kernel timeouts when the windowing system is running, and this is easily done by setting a special "Interactive" configuration flag to "false", in xorg.conf in the "Device" block for each GPU. The following is an example "Device" section from an HPC-oriented `xorg.conf` file. (see [ NVIDIA README X Config Options section for details][1])

```bash
Section "Device"
    Identifier     "Device0"
    Driver         "nvidia"
    VendorName     "NVIDIA Corporation"
    BusID          "PCI:132:0:0"
    ##
    ## disable display probing, display mode validation, etc. 
    ##
    Option         "UseDisplayDevice" "none"
    ##
    ## disable watchdog timeouts for long-running CUDA kernels
    ##
    Option "Interactive" "false"
EndSection
```

The `xorg.conf` configuration example snippet shown above is what I use for the *NVIDIA Tesla K80* cards on a headless remote visualization server running the VTD simulation software, but is also very similar to what is used on nodes for autonomous driving or other industry simulations.

## Setup our rig
You can find a repo with a fully automated full setup at this [Github Repo](https://github.com/aheumaier/azure-nvidia-linux-desktop) 


### Bootstrap with Terraform

Running `make deploy` will build a remote desktop enabled Ubuntu machine in a new resource group.
This will deploy a Azure NV6 Instance with a Nvidia Tesla M60 for you 
- Setup KDE desktop environment
- Setup Nvidia enabled Xserver
- Setup X11VNC remote desktop server


```bash
~$ make deploy  
```

You can connect now to the box with any VNC-Viewer using the hostname as session password
Open a terminal e.g `konsole` and validate the results: 


### Setup the node with Packer

Running  `make packer` will build a remote desktop enabled Ubuntu Image in you resource group to use for your own aplicances later:

```
~$ make install  
```

## References

- [HPC Visualization on NVIDIA Tesla GPUs](https://devblogs.nvidia.com/hpc-visualization-nvidia-tesla-gpus/)
- [Using CUDA and X](https://nvidia.custhelp.com/app/answers/detail/a_id/3029/~/using-cuda-and-x)
- [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker) 
