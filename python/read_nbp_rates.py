# python read_nbp_rates.py -c test.csv -d "Date acquired" -r "Cost basis"

import csv
import requests
import argparse
from datetime import datetime

NBP_API_URL_TEMPLATE = 'http://api.nbp.pl/api/exchangerates/rates/a/{curr}/{date}'
NPB_API_DATE_FORMAT = "%Y-%m-%d"

parser = argparse.ArgumentParser()
parser.add_argument("-c", "--csv-file", help="File in CSV format with transaction to processs")
parser.add_argument("-d", "--date-column", help="Name of column in CSV file that contains data");
parser.add_argument("-r", "--rate-column", help="Name of column in CSV file that contains foreign currency rate to be converted");
parser.add_argument("--currency", default="usd")
parser.add_argument("-f", "--source-date-format", help="Date format used in CSV file", default=NPB_API_DATE_FORMAT)
parser.add_argument("-y", "--year", default=2024)
args = parser.parse_args()

interests_to_check = []

with open(args.csv_file, newline="") as csvFile:
    reader = csv.DictReader(csvFile)
    start, end = datetime(args.year, 1, 1, 0, 0), datetime(args.year, 12, 31, 23, 59)
    for row in reader:
        row_date = row[args.date_column]
        try:
            date = datetime.strptime(row_date, args.source_date_format)
        except ValueError as e:
            print(f"Parsing '{row_date}' with format {args.sorce_date_format} failed, review '--source-date-format' cli args, exiting...")
            exit(1)
        if start > date or date > end:
            print(f"Date '{date}' not within bounds of year '{args.year}', skipping...")
            continue
        row_col = args.rate_column
        if (len(row[row_col]) != 0):
            api_req_date = datetime.strftime(date, NPB_API_DATE_FORMAT)
            interest = row[row_col]

            interests_to_check.append({
                'date': api_req_date,
                'interest': interest
            })

# TODO: additional arg param to append converted results into column?
for to_check in interests_to_check:
    url = NBP_API_URL_TEMPLATE.format(curr=args.currency, date=to_check['date'])
    r = requests.get(url)
    data = r.json()

    # TODO: what else present there?
    print(data['rates'][0])
