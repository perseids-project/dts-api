if Rails.env.development?
  Rails.application.configure do
    config.after_initialize do
      Bullet.enable = true
      Bullet.rails_logger = true
    end
  end
end

if Rails.env.test?
  Rails.application.configure do
    config.after_initialize do
      Bullet.enable = true
      Bullet.raise = true
    end
  end
end
