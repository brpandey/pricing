# Pricing

### Description

Small client library with database to track price changes for products 
with fictitious products API

### Assumptions

Each unique product record correlates to a unique product_external_id
Hence product_external_id is a unique index on the products table

Secret credentials should be stored in a .env file and not checked in.  
A sample.env file is stored in the root directory for illustrative purposes with 
the sample secret api key.  The .env file should be sourced before running.

### Libraries 

- ecto (db interaction wrapper, query generator) 
- postgrex (ecto postgres db adapter)
- quantum (for cron like behavior of running update monthly)
- timex (for api query params start and end date even though they are currently not used)
- poison (json decoder and encoder)
- httpoison (http library)

### Task
Create an application that will track pricing information for products. Product price information will be fetched from an external API, "Omege Pricing Inc." a ficticious company and API, and stored in your application.
 
The database should have a products table with the following fields:
- id
- external_product_id (which is the id that the external vendor, Omega Pricing Inc., uses), 
- price (in cents),
- product_name
- inserted_at (timestamp)
- updated_at (timestamp)
 
 
Each product may be associated with many past_price_records, which is a separate table. A past price record is a record of what the price of something used to be at some point. The past price record has the following fields:
- id
- product_id (a foreign key to products)
- price (again in cents)
- percentage_change (float)
- inserted_at (timestamp)
- updated_at (timestamp)
 
Your API key for Omega Pricing is "abc123key".
 
The application should fetch the product records from the Omega Pricing API monthly.
 
The process for the update is:
 
## Get the product records
 
Make a GET request to https://omegapricinginc.com/pricing/records.json passing the following URL parameters:
 
- key: `api_key` value: your API key
- key: `start_date` value: one month ago
- key: `end_date` value: today
 
Please use your favourite HTTP library for this purpose.
 
An example JSON payload from the endpoint would look like this:
 
```
{
"productRecords": [
{
"id": 123456,
"name": "Nice Chair",
"price": "$30.25",
"category": "home-furnishings",
"discontinued": false
},
{
"id": 234567,
"name": "Black & White TV",
"price": "$43.77",
"category": "electronics",
"discontinued": true
}
]
}
```
 
## Process the request records
Process the records as follows:
 
* If there's an existing product with an external_product_id that matches the id of a product in the response, it has the same name and the price differs, create a new past price record for the product. Then update the product's price. Do this even if the item is discontinued.
 
* If there is not an existing product with a matching external_product_id and the product is not discontinued, create a new product record for it. Explicitly log that there is a new product and that you are creating a new product.
 
* If there is an existing product record with a matching external_product_id, but a different product name, log an error message that warns the team that there is a mismatch. Do not update the price.



# Thanks! 
Bibek Pandey