# TODO: some other api call to verify that given product with id exists?
import requests

COUNTRY_CODE="PL"
PACKAGE_ID="1343233909655343234"
API_URL=f"https://api.steampowered.com/IPhysicalGoodsService/CheckInventoryAvailableByPackage/v1?origin=https:%2F%2Fstore.steampowered.com&country_code={COUNTRY_CODE}&packageid={PACKAGE_ID}"

# TODO: pick random UA from some predefined list?
r = requests.get(API_URL)
print(r.json())
