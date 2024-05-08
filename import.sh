
OUTFILE=mimic3.db

if [ -s "$OUTFILE" ]; then
    echo "File \"$OUTFILE\" already exists." >&2
    exit 111
fi

for FILE in *; do
    # skip loop if glob didn't match an actual file
    [ -f "$FILE" ] || continue
    # trim off extension and lowercase file stem (e.g., HELLO.csv -> hello)
    TABLE_NAME=$(echo "${FILE%%.*}" | tr "[:upper:]" "[:lower:]")
    case "$FILE" in
        *csv)
            IMPORT_CMD=".import $FILE $TABLE_NAME"
        ;;
        # need to decompress csv before load
        *csv.gz)
            IMPORT_CMD=".import \"|gzip -dc $FILE\" $TABLE_NAME"
        ;;
        # not a data file so skip
        *)
            continue
        ;;
    esac
    echo "Loading $FILE."
    sqlite3 $OUTFILE <<EOF
.headers on
.mode csv
$IMPORT_CMD
EOF
    echo "Finished loading $FILE."
done

echo "Finished loading data into $OUTFILE."