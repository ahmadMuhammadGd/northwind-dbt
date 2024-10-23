








log_file="/home/ahmad/repo/northwindDWH/log.txt"

for path in /home/ahmad/repo/northwindDWH/northwind/models/marts/*/*.sql; do
    echo "" >> "$log_file"
    echo "-- $path" >> "$log_file"
    echo "" >> "$log_file"
    cat "$path" >> "$log_file"
    echo "" >> "$log_file"
    echo "-----------------------------------------------------------" >> "$log_file"
    echo "" >> "$log_file"
done
