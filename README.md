# NASA Log File Analysis

This repository contains a Bash script (`log_analyzer.sh`) designed to analyze the NASA HTTP access log (`NASA_access_log_Jul95`) and generate detailed statistics as per the project requirements. The script processes the log file to extract insights such as total requests, unique IP addresses, failure rates, daily averages, and request trends. This document explains the project's purpose, setup, execution, error handling, findings, and analysis suggestions.

## Project Objective

The goal is to analyze the `NASA_access_log_Jul95` file to:
1. Count total, GET, and POST requests.
2. Identify unique IP addresses and their GET/POST request counts.
3. Calculate failed requests (4xx/5xx status codes) and their percentage.
4. Find the most active IP address.
5. Compute daily average requests.
6. Identify days with the highest failure counts.
7. Analyze requests by hour and detect trends.
8. Provide a status code breakdown.
9. Determine the most active IPs for GET and POST requests.
10. Investigate patterns in failure requests.
11. Offer suggestions to improve system performance and security.

## Prerequisites

To run the script, you need:
- **Tools**: `bash`, `awk`, `grep`, `sort`, `uniq`, `column` (standard on Linux systems).
- **Log File**: The `NASA_access_log_Jul95` file, which contains HTTP access logs in the Common Log Format. To download it, run:
  ```bash
  wget https://ita.ee.lbl.gov/traces/NASA_access_log_Jul95.gz
  gunzip NASA_access_log_Jul95.gz
