#!/bin/bash

# Set locale to handle non-ASCII characters
export LC_ALL=C

LOG_FILE="NASA_access_log_Jul95"

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' not found!" >&2
    exit 1
fi

echo "=== Log File Analysis ==="

# 1. Total Requests (count only valid HTTP log lines)
total_requests=$(awk '/\[.*\] "[A-Z]+ .* HTTP\// {count++} END {print count+0}' "$LOG_FILE")
echo "Total Requests: $total_requests"

# 2. GET and POST Requests
get_requests=$(grep -a -c '"GET ' "$LOG_FILE")
post_requests=$(grep -a -c '"POST ' "$LOG_FILE")
echo "GET Requests: $get_requests"
echo "POST Requests: $post_requests"

# 3. Unique IPs and Requests per IP
unique_ips=$(awk '/\[.*\] "[A-Z]+ .* HTTP\// {print $1}' "$LOG_FILE" | sort | uniq | wc -l)
echo "Total Unique IPs: $unique_ips"
echo -e "\nRequests per IP (GET/POST):"
awk '/\[.*\] "[A-Z]+ .* HTTP\// {
    ip=$1; method=$6; gsub("\"", "", method);
    if(method=="GET") get[ip]++;
    else if(method=="POST") post[ip]++
}
END {
    for (ip in get) print ip, "GET:", get[ip]+0, "POST:", post[ip]+0;
    for (ip in post) if (!(ip in get)) print ip, "GET:", 0, "POST:", post[ip]+0
}' "$LOG_FILE" | sort | column -t

# 4. Failed Requests (4xx/5xx)
failures=$(awk '/\[.*\] "[A-Z]+ .* HTTP\// {code=$9} code ~ /^[45][0-9][0-9]$/ {count++} END {print count+0}' "$LOG_FILE")
fail_percent=$(awk -v total="$total_requests" -v failed="$failures" 'BEGIN {printf "%.2f", (failed/total)*100}')
echo "Failed Requests: $failures"
echo "Failure Percentage: $fail_percent%"

# 5. Most Active IP
echo -e "\nMost Active IP:"
awk '/\[.*\] "[A-Z]+ .* HTTP\// {print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -1 | awk '{print $2, "(" $1 " requests)"}'

# 6. Daily Average Requests
days=$(awk '/\[.*\] "[A-Z]+ .* HTTP\// {match($0, /\[([0-9]{2})\/([A-Za-z]+)\/([0-9]{4})/, d); print d[1]"/"d[2]"/"d[3]}' "$LOG_FILE" | sort | uniq | wc -l)
daily_avg=$(awk -v total="$total_requests" -v days="$days" 'BEGIN {printf "%.0f", total/days}')
echo "Daily Average Requests: $daily_avg"

# 7. Day with Most Failures
echo -e "\nDay with Most Failures:"
awk '/\[.*\] "[A-Z]+ .* HTTP\// && $9 ~ /^[45][0-9][0-9]/ {
    match($0, /\[([0-9]{2})\/([A-Za-z]+)\/([0-9]{4})/, d);
    print d[1]"/"d[2]"/"d[3]
}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -1 | awk '{print $2, "(" $1 " failures)"}'

# 8. Requests by Hour (Fixed)
echo -e "\nRequests per Hour:"
awk '/\[.*\] "[A-Z]+ .* HTTP\// {
    if (match($0, /\[[^:]+:([0-9]{2}):[0-9]{2}:[0-9]{2}/, a)) {
        hour = a[1]
        if (hour >= 0 && hour <= 23) {
            count[hour]++
        }
    }
}
END {
    for (h = 0; h < 24; h++) {
        printf "Hour %02d : %d\n", h, count[h]+0
    }
}' "$LOG_FILE" | sort -k2n

# 9. Status Code Breakdown
echo -e "\nStatus Code Frequency:"
awk '/\[.*\] "[A-Z]+ .* HTTP\// {print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr | awk '{print "Code", $2, ":", $1}'

# 10. Most Active IP by GET/POST
echo -e "\nMost Active IP by GET:"
grep -a '"GET ' "$LOG_FILE" | awk '/\[.*\] "[A-Z]+ .* HTTP\// {print $1}' | sort | uniq -c | sort -nr | head -1 | awk '{print $2, "(" $1 " GETs)"}'
echo "Most Active IP by POST:"
grep -a '"POST ' "$LOG_FILE" | awk '/\[.*\] "[A-Z]+ .* HTTP\// {print $1}' | sort | uniq -c | sort -nr | head -1 | awk '{print $2, "(" $1 " POSTs)"}'

# 10.1 Top 4 IPs making GET requests
echo -e "\nTop 4 IPs with most GET requests:"
grep -a '"GET ' "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -4 | awk '{print $2, "(" $1 " GETs)"}'

# 10.2 Top 4 requested URLs using GET
echo -e "\nTop 4 URLs requested via GET:"
grep -a '"GET ' "$LOG_FILE" | awk -F\" '{print $2}' | awk '{print $2}' | sort | uniq -c | sort -nr | head -4 | awk '{print $2, "(" $1 " times)"}'

# 10.3 Top 4 IPs making POST requests
echo -e "\nTop 4 IPs with most POST requests:"
grep -a '"POST ' "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -4 | awk '{print $2, "(" $1 " POSTs)"}'

# 10.4 Top 4 requested URLs using POST
echo -e "\nTop 4 URLs requested via POST:"
grep -a '"POST ' "$LOG_FILE" | awk -F\" '{print $2}' | awk '{print $2}' | sort | uniq -c | sort -nr | head -4 | awk '{print $2, "(" $1 " times)"}'

# 11. Failure Patterns by Hour (Fixed)
echo -e "\nFailure Requests by Hour:"
awk '/\[.*\] "[A-Z]+ .* HTTP\// && $9 ~ /^[45][0-9][0-9]/ {
    if (match($0, /\[[^:]+:([0-9]{2}):[0-9]{2}:[0-9]{2}/, a)) {
        hour = a[1]
        if (hour >= 0 && hour <= 23) {
            count[hour]++
        }
    }
}
END {
    for (h = 0; h < 24; h++) {
        printf "Hour %02d : %d\n", h, count[h]+0
    }
}' "$LOG_FILE" | sort -k3nr

# 12. Request Trends (Fixed)
echo -e "\nRequest Trends:"
awk '/\[.*\] "[A-Z]+ .* HTTP\// {
    match($0, /\[.*:([0-9]{2}):/, a);
    hour=a[1]+0;
    if (hour >= 0 && hour <= 23) count[hour]++;
}
END {
    for (h=0; h<24; h++) {
        c = count[h]+0;
        if (c > 0) {
            if (h > 0 && count[h-1]+0 > 0) {
                trend = (c > count[h-1]) ? "Increasing" : "Decreasing";
                printf("Hour %02d : %d (%s from Hour %02d)\n", h, c, trend, h-1);
            }
        }
    }
}' "$LOG_FILE"
