# CFS vs. EEVDF: Real-Time Scheduler Benchmarking for Automotive Edge Computing

## Overview
This repository contains the complete benchmarking suite, datasets, and statistical analysis for an empirical evaluation of Linux kernel schedulers. It specifically compares the legacy Completely Fair Scheduler (CFS) against the modernized Earliest Eligible Virtual Deadline First (EEVDF) algorithm. 

Motivated by the strict microsecond timing requirements of automotive Advanced Driver Assistance Systems (ADAS) such as Brake-by-Wire, this project measures scheduling latency and context-switching efficiency under heavy, isolated resource contention.

**Academic Context:** Operating Systems Project (2025/2026) | University of Messina

## Repository Structure

### Documentation
* **`Final_Report.pdf`**: The comprehensive technical report detailing the hardware methodology, exploratory data analysis, inferential statistical proofs (Mann-Whitney U), and final conclusions.
* **`presentation.pdf`**: A 10-slide high-level summary deck of the project's hypothesis and findings.

### Source Code
* **`collect_data.sh`**: A bare-metal Bash script that configures CPU core isolation (`isolcpus`), generates IPC contention using `hackbench`, and captures raw scheduling latency via `cyclictest` and hardware context switches via a `perf` binary bypass.
* **`analysis.ipynb`**: The Python/Jupyter Notebook pipeline used to process the CSV data, calculate p99 tail latencies, run normality/inferential tests (SciPy), and generate the academic visualizations (Seaborn/Matplotlib).

### Datasets
* **`dataset_CFS.csv`**: Empirical latency and hardware metrics captured on Linux Kernel 6.5.0.
* **`dataset_EEVDF.csv`**: Empirical latency and hardware metrics captured on Linux Kernel 6.17.x.

## How to Run the Analysis Pipeline

**1. Environment Setup**
Ensure you have Python 3 installed. It is recommended to run this inside a virtual environment:
```bash
python3 -m venv env
source env/bin/activate
pip install pandas numpy scipy matplotlib seaborn jupyter
