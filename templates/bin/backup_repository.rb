# frozen_string_literal: true

module SGH
  module DeleteChildrenIf
    def delete_child_if
      children.each do |child|
        child.delete if yield child
      end
    end
  end

  module DateCalculations
    def last_day_of_month
      Date.new(year, month, -1)
    end

    def last_day_of_month?
      self == last_day_of_month
    end
  end

  #
  # Someone else puts a backup into root/daily, and we copy
  # it into weekly / monthly / yearly.
  # We also ensure that the retention in daily, weekly,
  # monthly, and yearly is limited to a maximum number of
  # files per period.
  #
  class BackupRepository
    attr_reader :root

    def initialize(root)
      @root = root
    end

    def retain!
      retain_daily
      retain_weekly if today.sunday?
      retain_monthly if today.last_day_of_month?
    end

    private

    def retain_daily
      folder('daily').delete_child_if { |c| c.mtime.to_date <= today - 7 }
    end

    def retain_weekly
      FileUtils.cp(latest_backup, folder('weekly'))
      folder('weekly').delete_child_if { |c| c.mtime.to_date <= today - 4 * 7 }
    end

    def retain_monthly
      FileUtils.cp(latest_backup, folder('monthly'))
      folder('monthly').delete_child_if { |c| c.mtime.to_date <= last_day_of_six_months_ago(today) }
    end

    def folder(name)
      (root / name).tap(&:mkpath).extend(DeleteChildrenIf)
    end

    def today
      @today ||= Time.now.utc.to_date.extend(DateCalculations)
    end

    def todays_backups
      folder('daily').children.select { |f| f.mtime.to_date == today }.sort_by(&:mtime)
    end

    def latest_backup
      todays_backups.last or raise "Could not find daily backup for #{today} in #{folder('daily')}"
    end

    def last_day_of_six_months_ago(date)
      today_in_cutoff_month = date << 6
      Date.new(today_in_cutoff_month.year, today_in_cutoff_month.month, -1)
    end
  end
end
