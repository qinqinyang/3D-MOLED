# SMRI (Simulation Artist of MRI) platform
**Version:** 2.3.2  
**Release Date:** **2025-07-30**  
**Contributors:**  [Haitao Huang](https://github.com/hei6775) and [Qinqin Yang](https://github.com/qinqinyang)  
**Affiliation:**  [**XMU-SMRI Lab**](https://smri.xmu.edu.cn), Department of Electronic Science, Xiamen University, China  

# 1. What is SMRI
**SMRI** (*Simulation Artist of MRI*) is a **powerful framework** for rapid **2D and 3D MRI simulation**.  It is designed to be **easy to learn and use**, while delivering **high performance** and **high quality** with minimal code.  Most of the SMRI code base is written in **C++** for efficiency, and it leverages **GPU acceleration** via **CUDA** to perform complex magnetic resonance imaging simulations at scale.  

> **Development History**  
> SMRI was initially developed in **2021** by *Haitao Huang* and *Qinqin Yang*, primarily for generating deep learning training datasets within the laboratory.

---

**Note:** This compiled version is intended **exclusively** for **3D-MOLED** and is **not a general-purpose release**.

📩 **Interested in the full SMRI framework?**  
Please contact **Qinqin Yang** at [qinqin.yang@uci.edu](mailto:qinqin.yang@uci.edu).

---

**Reference:**  
Yang QQ, Huang HT, Yong HT, *et al.* **SMRI: Next-generation MRI simulation platform for training data generation in the era of AI.** In *Proceedings of the 33rd Joint ISMRM & ISMRT Annual Meeting*. Honolulu, Hawaii, US; 2025. p. 0009.

# 2. Environment Setup

Modify the environment variables
`/home/your_user_name/.bashrc` according to the actual setup:
```bash
# cuda
export PATH="/usr/local/cuda-12.2/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda-12.2/lib64:$LD_LIBRARY_PATH"
# MATLAB
export PATH="/home/yqq/Env/MATLAB/bin/:$PATH"
# cmake
export PATH="/home/yqq/Env/cmake-3.24.0-linux-x86_64/bin:$PATH"
# gcc
export LD_LIBRARY_PATH="/home/yqq/Downloads/gcc/lib/:$LD_LIBRARY_PATH"
export PATH="/home/yqq/Downloads/gcc/bin:/home/yqq/Downloads/gcc/lib64:$PATH"
```
Use source to apply the changes
```bash
source /home/your_user_name/.bashrc
```

# 3. How to Run
You can directly execute the following command in the build directory:
```bash
./simu_bin
```
(Before running, remember to modify the **configs/mainCfg.json** and **seqs/GREOLEDMS3Dp3_BUDA/seqGREOLEDMS3Dp3_BUDA.json** configuration file, such as the input and output directories, etc.) to run the simulation program.

You can also run it in the background using:
```bash
nohup ./simu_bin >../my.log 2>&1 &
```

# 4. Key Parameter Description (mainCfg.json) 
```json
{
    // Sequence Name
    "SeqName": "GREOLEDMS3Dp3_BUDA",

    // Directory of Virtual Imaging Objects (VObj)
    "SrcRoot": "Template_SMRI_niubi1_1/",

    //Directory of Simulated Output Signals
    "DstRoot": "Dataset_SMRI_scan/scan",

    // Number of Generated Samples
    "FileNum": 5280,

    // Number of Simulated Spins
    "SpinNum": 1,

    // Starting File Index
    "StartFileIndex": 0,

    // GPU Index
    "GPUID": 0,

    // Dimensions of the generated k-space
    "XN": 224,
    "YN": 216,

    // Number of grids of the virtual imaging object
    "ModelXN": 512,
    "ModelYN": 512,

    // Resolution of the virtual imaging object (m)
    "ModelXRes": 0.00044,
    "ModelYRes": 0.00044,

    // Number of k-space
    "KSpaceNum": 2
}
```

# 5. Key Parameter Description (seqGREOLEDMS3Dp3_BUDA.json) 
```json
{
    "RFInterval": 20e-6,
    "ShiftUseBlipT": true,

    // TR (s)
    "TR": 0.088,

    // Dummy scan for steady-state
    "DummyScan": 10,

    // Gn
    "Shiftrewind": 216,

    // Properties of Pulse 1 and Echo-shifting 1
    "RF1": {
        "MiddleStamp": 0.0,
        "RfFlipAngle": 10,
        "RfDt": 0.0005,
        "RfPhase": 0,
        "RfFreq": 1.5707963267948966
    },
    "ShiftG1": {
        "MiddleStamp": 0.0025,
        "Duration": 0.001,
        "XGradient": 56,
        "YGradient": -56,
        "ZGradient": 0
    },

    // Properties of Pulse 2 and Echo-shifting 2 
    "RF2": {
        "MiddleStamp": 0.0045,
        "RfFlipAngle": 10,
        "RfDt": 0.0005,
        "RfPhase": 0,
        "RfFreq": 1.5707963267948966
    },
    "ShiftG2": {
        "MiddleStamp": 0.0070,
        "Duration": 0.0005,
        "XGradient": 56,
        "YGradient": -56,
        "ZGradient": 0
    },

    // Properties of Pulse 3 and Echo-shifting 3 
    "RF3": {
        "MiddleStamp": 0.0090,
        "RfFlipAngle": 10,
        "RfDt": 0.0005,
        "RfPhase": 0,
        "RfFreq": 1.5707963267948966
    },
    "ShiftG3": {
        "MiddleStamp": 0.011,
        "Duration": 0.0005,
        "XGradient": 52,
        "YGradient": -56,
        "ZGradient": 0
    },

    // Number of shot
    "ShotNum": 8,

    // Echo train length
    "ETL": 27,

    // Number of slices per volume
    "Slices": 110,

    // Ramp sampling rate
    "SamplingRate": 1,

    // First echo train start time
    "LastRelaxTime": 0.01373,

    // The time interval between echo trains
    "LastRelaxTime2": 0.0023,

    // randomization of echo-shifting gradients
    "ShiftGraFlag":true,
    "XMinShiftGra":-0.05,
    "XMaxShiftGra":0.05,
    "YMinShiftGra":-0.05,
    "YMaxShiftGra":0.05,
    "ZMinShiftGra":0,
    "ZMaxShiftGra":0
}
```
