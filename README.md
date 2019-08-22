# Airtable => Clubhouse importer

# Overview

Migrate tickets from [Airtable](https://airtable.com) to [Clubhouse](https://clubhouse.io).

# Requirements

* Ruby
* Bundler

### Setup

* Install Gems

```
bundle install
```

* Set up API keys in `.env` (for `dotenv`)

Copy the example `.env`:

```
cp .env.example .env
```

Now set the following values:

#### `CLUBHOUSE_API_KEY`

Find this at `https://app.clubhouse.io/<your_org>/settings/account/api-tokens`

#### `CLUBHOUSE_PROJECT_ID`

Your Clubhouse project ID. Find this by visiting `https://app.clubhouse.io/<your_org>/projects`. Then clicking the project, and find the project ID in the URL:

=> `https://app.clubhouse.io/<your_org>/project/{{ your_project_id }}/<your_project_name>`

#### CLUBHOUSE_WORKFLOW_STATE_ID

The workflow state ID for all of your migrated tickets. (You could also customize the script to pull this value from an Airtable column.)

This can be tricky to find. I got it by starting IRB, and pasting in the following script:

*(Note: You must first set your `CLUBHOUSE_API_KEY`*)

```ruby
require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require 'active_support/core_ext'
require 'active_support/json'
require 'awesome_print'

require 'clubhouse'

Clubhouse.default_client = Clubhouse::Client.new(ENV['CLUBHOUSE_API_KEY'])
ap Clubhouse::Workflow.all.first.states.map { |s| {id: s.id, name: s.name } }
```

This will print all the state IDs and names for your first workflow:

```
2.5.5 :060 > ap Clubhouse::Workflow.all.first.states.map {|s| {id: s.id, name: s.name }}
[
    [0] {
          :id => 500000008,
        :name => "Untriaged Bugs"
    },
    [1] {
          :id => 500000019,
        :name => "Unscheduled"
    },
    [2] {
          :id => 500000007,
        :name => "Ready for Development"
    },
    ...
]
 => nil
```

#### `AIRTABLE_API_KEY`

You can find your Airtable API key at: https://airtable.com/account

#### `AIRTABLE_APP_KEY`

Visit https://airtable.com/api, then choose your base. The app key will be visible in the URL:

=> `https://airtable.com/{{ your app key }}/api/docs#curl/introduction`


#### `AIRTABLE_TABLE_NAME`

The name of the table in your Airtable base. (Case sensitive.)

# Field Mapping

Your Airtable table must have the following columns:

* `Status` (text, single select, multi select, etc.)
  * The value of this field must be `Todo`. Any other values will cause the row to be ignored. (I didn't want to import any completed tickets.)
  * (*Feel free to extend the script with a mapping from Airtable states to Clubhouse workflow states.*)
* `Export` (text, single select, multi select, etc.)
  * This value must be set to `Clubhouse`. Any other values will cause the row to be ignored.
* `Type` (text or multi select)
  * The type of your Clubhouse story. Must be one of: `Bug`, `Feature`, `Chore`.
* `Imported` (boolean)
  * The import script will set this value to true once the Clubhouse story has been created. (Prevents duplicate stories if you need to re-run the script.)
* `Priority` (text, single select, multi select, etc.)
  * The priority of your ticket. I used the following options: `Critical`, `Important`, `High`, `Medium`, `Low`, `Much Later`. I decided to create labels in Clubhouse for each of these priorities. (*Feel free to modify or delete this part of the script.*)
* `Title` (text)
  * The title for your Clubhouse story
* `Description` (text)
  * The description for your Clubhouse story


# Run the script

After you have install the gems and configured all of the API keys in `.env`, run:

```bash
$ ./import.rb
```
