# XU3EM
XU3EM is a fork of the project [DATACOLLECT] (https://github.com/kranik/DATACOLLECT), and It contains modifications to work with kernel 4.14.y in Odroid-XU3.

# Requirements

This project is based on the latest version of Linux-Odroid kernel 4.14.y. You can download it [here] (https://wiki.odroid.com/odroid-xu4/os_images/linux/ubuntu_4.14/20180531). And, you can follow the [guide](https://wiki.odroid.com/troubleshooting/odroid_flashing_tools) for flashing it in emmc or sdcard.  You need to install these essentials packages:

- **Cpuset** is a python application that forms a wrapper around the
standard Linux filesystem calls to make using the cpusets facilities
in the Linux kernel easier. You can install it using `sudo apt-get install cpuset`.
- **cpufrequtils**  is used to control the CPU frequency scaling deamon. You can install it using `sudo apt-get install cpufrequtils`.
- **bc**  is an arbitrary precision numeric processing language with syntax similar to C. You can install it using `sudo apt-get install bc`.

# Usage

The main script to run parsec in parallel with sensor collection is `MC_XU3.sh`. It demands some options to run. You can type '--help' for help.
- **b** [NUMBER] -> Turn on collection for big cores [benchmarks and monitors]. Specify the number of cores to involve.
- **L** [NUMBER] -> Turn on collection for LITTLE cores [benchmarks and monitors]. Specify the number of cores to involve.
- **f** [FREQUENCIES] -> Specify frequencies in Hz, separated by commas. The range is determined by core type. First core type.
- **q** [FREQUENCIES] -> Specify frequencies in Hz, separated by commas. The range is determined by core type. Second core (if selected).
- **s** [DIRECTORY] -> Specify a save directory for the results of the different runs. If the flag is not specified program uses the current directory.
- **x** [DIRECTORY] -> Specify the benchmark executable to be run. If multiple benchmarks are to run, so put them all in a script.
- **e** [DIRECTORY] -> Specify the events to be collected. Event labels must be on line 1, separated by commas. Event RAW identifiers must be specified on line 2, separated by commas.
- **t** [NUMBER] -> Specify the sensor sampling time. It needs to be a positive integer.
- **n** [NUMBER] -> specify number of runs. Results from different runs are saved in subdirectories.

Mandatory options are: -b/-L [1-4] -f [FREQ LIST] -x [DIR] -t [NUM] -n [NUM]

Example of use:

`./MC_XU3.sh -b 4 -L 4 -f 1800000,1500000,1200000 -q 1400000,1000000,600000 -n 2 -x PATH_TO/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh -t 500000000 -s PATH_TO/results/`

<!-- /MC_XU3.sh -b 1 -L 1 -f 200000 -q 200000 -n 1 -x /home/reginaldojunior/Documentos/UFscar/parsec-2.1/exec.sh -t 1 -->

The benchmark runs twice and the sensor information is captured in parallel. The frequency of cores is fixed at  1800000, 1500000, 1200000 kHz for big cores and 1400000, 1000000, 600000 kHz for LITTLE cores. 

The results will be saved in `PATH_TO/results/` and the `PATH_TO/Workloads/parsec-3.0/parsec_benchlist_timestamp_cset.sh` is a script to specify the parsec executable applications. You can choose the parsec application to run by modifying the [bench_list.data](Workloads/parsec-3.0/bench_list.data). For that, you need to remove the '#' character from the beginning of the line which has the respective parsec application name.

You can use the modified [wrap_noevents_PARSEC_.sh](ODROID_XU3/wrap_noevents_PARSEC_.sh) script to run your benchmarks. It modifies the bench_list.data before execution.

# Troubleshooting

## Update problems

If you have "Release file expired" problem, then double check the date and time of your system.

## INA231 Sensor Module Problem

If you have any problems with the in231 driver, then follow the steps:

1. Use the command `lsmod` to check if `ina231_sensor module` is loaded.
2. If it is not loaded, then use the command `modprobe ina231-sensor`.
3. Execute `lsmod` again.
4. If `ina231_sensor` is loaded, use the [sensor_test](ODROID_XU3/XU3_Sensors/sensors_test.sh) script to check the `ina213_sensor`

If any errors persist, then, probably, it is a problem with the board-name auto-detection feature. It detects if the board is XU3 or XU4. Then, you must edit the `/media/boot/boot.ini` file to load xu3 dtb manually. You can download the modified file [here](https://www.dropbox.com/s/s2cz70m47xr4ikk/boot.ini?dl=0).
