# python read_nbp_rates.py -c test.csv -d "Date acquired" -r "Cost basis"

import sys
import csv
import requests
import shutil
from argparse import Namespace, ArgumentParser
from datetime import datetime, timedelta, timezone
from requests.exceptions import RequestException
from dataclasses import dataclass, field
from decimal import Decimal
from typing import Optional, List, Union

NBP_API_URL_TEMPLATE = 'http://api.nbp.pl/api/exchangerates/rates/a/{curr}/{date}'
NPB_API_DATE_FORMAT = "%Y-%m-%d"

info = sys.version_info
major, minor = info.major, info.minor
 
if (major == 3 and minor < 7):
    print(f"using py version: {major}.{minor} that has unordered dicts (no guarantee when operating on csv rows in reader > writer steps), exiting...")
    exit(1)

parser = ArgumentParser()
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
    _src_value: Decimal = field(init=False, repr=False)
    rate: Optional[Decimal] = None # filled after quering nbp api   

    def __init__(self, date: datetime, src_value: Union[str, Decimal], currency: str):
        self.date = date
        self.currency = currency
        self.src_value = src_value

    @property
    def src_value(self) -> Decimal:
        return self._src_value

    @src_value.setter
    def src_value(self, value: Union[str, Decimal]):
        if isinstance(value, str):
            self._src_value = Decimal(value)
        elif isinstance(value, Decimal):
            self._src_value = value
        else:
            raise TypeError(f"src_value must be Decimal/str, got {type(value)}")

    def value(self) -> Decimal:
        return self.rate * self.src_value 

    def api_req_url(self) -> str:
        api_date = datetime.strftime(self.date, NPB_API_DATE_FORMAT)
        return NBP_API_URL_TEMPLATE.format(curr=args.currency, date=api_date)


def process_csv():
    with open(args.csv_file, newline="") as csv_file:
        print("Processing CSV rows with reader...")
        interests = csv_reader_process_rows(csv_file, args)
        
    print("Processing rates/dates...")
    converted_interests = nbp_api_process(interests, args)

    # NOTE: handle not passed as we operate on copied file... initially was different idea, hence left as it is. add flag in the future to enable/disable copying?
    print("Writing rows with converted values...")
    csv_writer_process_rows(converted_interests, args)


def csv_reader_process_rows(csv_file_handle, args: Namespace) -> List[Conversion]:
    interests_to_check: List[Conversion] = []

    reader = csv.DictReader(csv_file_handle)
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
            # continue

        row_col = args.rate_column
    
        if (len(row[row_col]) != 0):
            interests_to_check.append(Conversion(date=date, src_value=row[row_col], currency=args.currency))

    return interests_to_check


def nbp_api_process(convs: List[Conversion], args: Namespace) -> List[Conversion]:
    for to_check in convs:
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

        api_result_value = data['rates'][0]['mid']
        print(f"\t\tValue at api: {api_result_value}")
        to_check.rate = Decimal(str(api_result_value))
        # tax = (amount * tax_rate).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)
    return convs


def csv_writer_process_rows(convs: List[Conversion], args: Namespace):
    for conv in convs:
        print(conv.value())
    
    now_str = datetime.strftime(datetime.now(timezone.utc), "%Y-%m-%d_%H-%m-%s")
    copied_csv_filepath = f"{args.csv_file}-{now_str}.csv"
    shutil.copy2(args.csv_file, copied_csv_filepath)

    with open(copied_csv_filepath, newline="") as csv_file:
        # TODO! 'fieldnames' to be extracted from initial csv file! in some previous steps?
        # writer = csv.DictWriter(csv_file)
        pass


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
        prev_date_conversion = Conversion(date=prev_date, currency=c.currency, src_value=c.src_value)
        return fetch_closest_possible_rate(prev_date_conversion, retry_count-1)


# TODO: csv writer - is there guarantee that it iterates sequentially bottom-down?
# TODO: csv writer - operate on copy of csv file, add timestamp to name
# TODO: additional arg param to append converted results into column? override if exists?

if __name__ == '__main__':
    process_csv()