#!/usr/bin/env ruby
puts "Starting Airtable => Clubhouse importer..."

require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require 'active_support/core_ext'
require 'active_support/json'
require 'awesome_print'
require 'yaml'

require 'airrecord'
require 'clubhouse'

Clubhouse.default_client = Clubhouse::Client.new(ENV['CLUBHOUSE_API_KEY'])

Task = Airrecord.table(
  ENV['AIRTABLE_API_KEY'],
  ENV['AIRTABLE_APP_KEY'],
  ENV['AIRTABLE_TABLE_NAME']
)

imported = 0
already_imported = 0

AT_CH_STORY_TYPES = {
  'Bug'=> :bug,
  'Feature' => :feature,
  'Chore' => :chore
}

puts "Fetching Clubhouse labels..."
ch_labels = Clubhouse::Label.all

puts "Fetching Airtable rows..."
Task.all.each do |at_record|
  next unless at_record['Status'] == 'Todo' &&
    at_record['Export'] == "Clubhouse"
  if at_record['imported']
    puts "Already imported: #{at_record['Title']}"
    already_imported += 1
    next
  end

  story_type = AT_CH_STORY_TYPES[at_record['Type']]
  raise "Unknown story type: #{at_record['Type']}" unless story_type

  # Create priority label if it doesn't already exist
  ch_label = ch_labels.find{ |l| l.name == at_record['Priority'] }
  unless ch_label
    ch_label = Clubhouse::Label.new(name: at_record['Priority'])
    ch_label.save
    ch_labels << ch_label
  end

  ch_story_attributes = {
    name: at_record['Title'],
    description: at_record['Description'],
    project_id: ENV['CLUBHOUSE_PROJECT_ID'],
    workflow_state_id: ENV['CLUBHOUSE_WORKFLOW_STATE_ID'],
    story_type: story_type,
    labels: [ { name: at_record['Priority'] } ],
    # deadline: '2016-12-31T12:30:00Z',
    # estimate: 1,
    # comments: [{ text: 'A comment to start the story' }],
    # tasks: []
  }
  ch_story = Clubhouse::Story.new(ch_story_attributes)

  puts "Creating story in Clubhouse:"
  ap ch_story_attributes

  ch_story.save
  raise "Could not save story!" unless ch_story.id
  imported += 1

  at_record['imported'] = true
  unless at_record.save
    raise "Could not save record #{record.id}! #{record['title']}"
  end
end

puts "Imported #{imported} stories into Clubhouse."
puts "#{already_imported} stories were already imported."
