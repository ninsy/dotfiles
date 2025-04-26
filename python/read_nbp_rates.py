# python read_nbp_rates.py -c test.csv -d "Date acquired" -r "Cost basis"

import sys
import csv
import requests
import argparse
from datetime import datetime, timedelta
from requests.exceptions import RequestException
from dataclasses import dataclass
from decimal import Decimal
from typing import Optional

NBP_API_URL_TEMPLATE = 'http://api.nbp.pl/api/exchangerates/rates/a/{curr}/{date}'
NPB_API_DATE_FORMAT = "%Y-%m-%d"

info = sys.version_info
major, minor = info.major, info.minor
 
if (major == 3 and minor < 7):
    print(f"using py version: {major}.{minor} that has unordered dicts (no guarantee when operating on csv rows in reader > writer steps), exiting...")
    exit(1)

parser = argparse.ArgumentParser()
parser.add_argument("-c", "--csv-file", help="File in CSV format with transaction to processs")
parser.add_argument("-d", "--date-column", help="Name of column in CSV file that contains data");
parser.add_argument("-r", "--rate-column", help="Name of column in CSV file that contains foreign currency rate to be converted");
parser.add_argument("--currency", default="usd")
parser.add_argument("-f", "--source-date-format", help="Date format used in CSV file", default=NPB_API_DATE_FORMAT)
parser.add_argument("-y", "--year", default=2024)
args = parser.parse_args()


@dataclass
class Conversion:
    date: datetime
    # NOTE: assume that always translated to PLN
    currency: str
    src_value: Decimal
    rate: Optional[Decimal] = None # filled after quering nbp api   

    def value(self) -> Decimal:
        return self.rate * self.src_value 

    def api_req_url(self) -> str:
        api_date = datetime.strftime(self.date, NPB_API_DATE_FORMAT)
        return NBP_API_URL_TEMPLATE.format(curr=args.currency, date=api_date)


def process_csv():
    interests_to_check = []

    with open(args.csv_file, newline="") as csvFile:
        reader = csv.DictReader(csvFile)
        start, end = datetime(args.year, 1, 1, 0, 0), datetime(args.year, 12, 31, 23, 59)
        print("Processing CSV rows with reader...")
        for row in reader:
            row_date = row[args.date_column]
            try:
                date = datetime.strptime(row_date, args.source_date_format)
            except ValueError as e:
                print(f"Parsing '{row_date}' with format {args.sorce_date_format} failed, review '--source-date-format' cli args, exiting...")
                exit(1)

            if start > date or date > end:
                print(f"Date '{date}' not within bounds of year '{args.year}', skipping...")
                # continue

            row_col = args.rate_column
        
            if (len(row[row_col]) != 0):
                interests_to_check.append(Conversion(date=date, src_value=row[row_col], currency=args.currency))

    print("Processing rates/dates...")
    for to_check in interests_to_check:
        url = to_check.api_req_url()
        try:
            r = fetch_closest_possible_rate(to_check)
        except Exception as e:
            print(f"Request HTTP failed for date|interest: {to_check['date']}|{to_check['interest']}")
            print(f"Requesting: GET {url}")
            print(e)
            r = None

        if r is None:
            continue

        try:
            data = r.json()
        except ValueError as e:
            print(f"JSON parsing failed for date|interest: {to_check['date']}|{to_check['interest']}")
            print(f"Requesting: GET {url}")
            print(f"{r.text}")
            print(e)
            data = None

        if data is None:
            continue

        # TODO: what else present there?
        print(data['rates'][0])
        # tax = (amount * tax_rate).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)


def fetch_closest_possible_rate(c: Conversion, retry_count=5):
    if retry_count == 0:
        raise Exception(f"Couldn't process for 5 consecutive days, exiting...")

    url = c.api_req_url()
    try:
        print(f"\tquerying at: {url}")
        r = requests.get(url)
        r.raise_for_status()
        return r
    except RequestException as e:
        # TODO: preserve e.message somehow?...
        prev_date = c.date - timedelta(days=1)
        prev_date_conversion = Conversion(date=prev_date, currency=c.currency, rate=c.rate, src_value=c.src_value)
        return fetch_closest_possible_rate(prev_date_conversion, retry_count-1)


# TODO: csv writer - is there guarantee that it iterates sequentially bottom-down?
# TODO: csv writer - operate on copy of csv file, add timestamp to name
# TODO: additional arg param to append converted results into column? override if exists?

if __name__ == '__main__':
    process_csv()