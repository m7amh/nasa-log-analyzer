# NASA Log File Analysis

This project contains a Bash script (`log_analyzer.sh`) to analyze the NASA HTTP access log (`NASA_access_log_Jul95`) and generate statistics as per the project requirements. The script processes the log file to provide insights such as request counts, unique IPs, failure rates, and request trends.

## Prerequisites

- **Tools**: Ensure you have `bash`, `awk`, `grep`, `sort`, `uniq`, and `column` installed (available by default on most Linux systems).
- **Log File**: The script requires the `NASA_access_log_Jul95` file. To download it, run the following commands:

```bash
wget https://ita.ee.lbl.gov/traces/NASA_access_log_Jul95.gz
gunzip NASA_access_log_Jul95.gz
