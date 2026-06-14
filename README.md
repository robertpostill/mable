# Robert's Response To The Mable Code Test
## Getting started
To run the code, you're going to want install the dependant gems.  To do that, run:
`bundle install`

## Running the tests
The test suite runs on
`bundle exec rspec`

## Running the code
I've set the project up to run two ways.  The development first method is via ruby, so:
`ruby mable.rb mable_account_balances.csv mable_transactions.csv`
While that's okay for devlopmnet if this was a thing I was distributing to others I wouldn't like it, so I also made a wrapper script. So you can also invoke it like this:
`./bin/mable_test.sh`
That will also check you have ruby installed and install the gem requirements if they aren't already there.

## Other matters
I've used rubocop, I could have used other tools in addition but that felt like overkill.


