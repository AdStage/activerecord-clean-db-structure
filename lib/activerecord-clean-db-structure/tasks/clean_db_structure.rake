require 'activerecord-clean-db-structure/clean_dump'

Rake::Task['db:structure:dump'].enhance do
  filenames = []
  filenames << ENV['DB_STRUCTURE'] if ENV.key?('DB_STRUCTURE')

  if ActiveRecord::VERSION::MAJOR >= 6
    ActiveRecord::Tasks::DatabaseTasks.for_each do |spec_name|
      Rails.application.config.paths['db'].each do |path|
        filenames << File.join(path, spec_name + '_structure.sql')
      end
    end
  end

  unless filenames.present?
    Rails.application.config.paths['db'].each do |path|
      filenames << File.join(path, 'structure.sql')
    end
  end

  filenames.each do |filename|
    cleaner = ActiveRecordCleanDbStructure::CleanDump.new(
      File.read(filename),
      **Rails.application.config.activerecord_clean_db_structure
    )
    cleaner.run
    File.write(filename, cleaner.dump)
  end
end
