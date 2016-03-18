# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
admin = User.create(first_name: 'Admin', last_name: '', email: 'admin@textile.com', password: 'chang3m3', password_confirmation: 'chang3m3', admin: true)
admin.confirm!
