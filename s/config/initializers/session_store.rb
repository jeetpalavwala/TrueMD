# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_s_session',
  :secret      => 'bdf87c368708e1b003041c3bb55738a4c78f52951c9306152a6333ae48db6d4134f9920b11cabf05eff48ab7b074b9ec56fdb28b27825340b6b93678d80fc812'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
