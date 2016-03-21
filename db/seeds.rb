# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
admin = User.create(first_name: 'Admin', last_name: '', email: 'admin@textile.com', password: 'chang3m3', password_confirmation: 'chang3m3', admin: true)
admin.confirm!

# Create employees
if ENV['WITH_SAMPLE_DATA']
  15.times do |n|
    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    bday = Faker::Time.between(60.years.ago, 20.years.ago, :all)

    employee = User.create({
      first_name:     first_name,
      last_name:      last_name,
      date_of_birth:  bday,
      email:          "#{first_name}-#{last_name}#{bday.year.to_s[2..4]}@textile.com",
      password: 'chang3m3',
      password_confirmation: 'chang3m3'
    })

    employee.confirm

    # Create checks
    45.times do |n| # For past 45 days
      past_day = Time.current.in_time_zone.ago((n+1).days)

      if rand > 0.1 # 10% probability of absence
        # Variation from -5 min to +20 min from the (rounded) CHECKIN_LIMIT_TIME: 9 hrs
        variation = (-5*60..20*60).to_a.sample
        employee.checks.create({
          created_at: past_day.change(hour: TimeRules::CHECKIN_LIMIT_TIME).in(variation)
        })

        # Variation from -5 min to +60 min from the (rounded) CHECKOUT_FROM_TIME: 18 hrs
        variation = (-5*60..60*60).to_a.sample
        employee.checks.create({
          created_at: past_day.change(hour: TimeRules::CHECKOUT_FROM_TIME).in(variation)
        })
      end
    end
  end
end

