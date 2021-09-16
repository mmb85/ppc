# Ppc

Given an array of clicks, return the subset of clicks where:
1. For each IP within each one hour period, only the most expensive click is placed into the result set.
2. If more than one click from the same IP ties for the most expensive click in a one hour period, only place the earliest click into the result set.
3. If there are more than 10 clicks for an IP in the overall array of clicks, do not include any of those clicks in the result set.
The result set should be stored in an array of objects. Each object should represent a click. The expected result set should be a subset of the original array.

## Installation


In root project folder execute:

    $ gem install bundler # may be not needed, depending on the tools instaled locally
    $ bundle install # or bin/setup


## Usage

An executable is placed under `bin/ppc` route. It can be executed providing the JSON file to be processed

    $ bin/ppc clicks.json

It will result on a console output with the processed JSON formatted to read it and also a new file `resultset.json` in root folder.

To run the test that cover all use cases please run:

    $ bundle exec rspec -fd

Expect a result like this: (-fd, full description, will provide context easier to review)
```
Ppc
  has a version number
  When the file contains more than 10 ocurrences of an IP
    should exclude it from the results
    should not exclude other valid data
  When the file contains 10 or less ocurrences of an IP
    When the same IP has more than one ocurrence per hour
      When the ocurrences has same amount value
        should include the first ocurrence by timestamp
      When the ocurrences has different amount value
        should include the most expensive
    When the same IP has only one ocurrence per hour
      should be included`
```

## Development
Not a lot of gems needed:
  - Used pry to debug during development
  - Used Rspec to create the test suite
  - Used rubocop to ensure good coding style
  - Used Simplecov to have test coverage report after test execution


The approach to grant a performant implementation was:
  - Group entire file by IPs
  - Reject all entries with more than 10 IPs ocurrences (it will avoid process more rows than needed)
  - With this small collection group by hours
    - Select only the most expensive click per hour
      - If there's more than one then pick the first by timestamp
  - Store everything in an Array and return it later in a JSON file

  * It was taken into account that the example file provided only include one-day clicks, so taken into account only the 24 periods regardless of the day to avoid extra complexity layer.

In terms of structure:
  - it was created a Ppc::ProcessInput under lib that will take care of apply the algorith and response with JSON file creation. I was thinking on separate JSON file generation in a different module but it could be overcomplicate the solution.
  - An executable is provided in `bin` folder that allow the entry of JSON file using the console
  - Test was stored in `spec` folder and a `support` folder was created to store de JSON files examples to be used
  - Inside `ppc_specs.rb` shared_context was created avoiding DRY when loading the JSON files examples