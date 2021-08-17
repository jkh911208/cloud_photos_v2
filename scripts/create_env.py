import os

f = open("./.env.example", "r")
example = f.read()
debug = example.format(API_URL="http://localhost", SECRET="verysecure")
open("./debug.env", "w").write(debug)

production = example.format(API_URL=os.environ.get(
    "API_URL"), SECRET=os.environ.get("SECRET"))
open("./production.env", "w").write(production)
