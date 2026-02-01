# Kindergarten ERP

A comprehensive enterprise resource planning system for kindergartens and early childhood establishments built with Ruby on Rails.

## Features

- Staff management
- Student enrollment and tracking
- Parent communication
- Attendance tracking
- Fee management
- Event planning and notifications
- Responsive web interface with modern UI

## Architecture

This application follows modern Rails architecture patterns:

### Design Patterns Used

1. **Service Objects** (`app/services/`): Encapsulate complex business logic
   - `AttendanceService`: Handles attendance marking with notifications
   - `FeeService`: Manages fee processing and reminders

2. **Decorators** (`app/decorators/`): Handle view-specific formatting
   - `StudentDecorator`: Formats student data for display

3. **Concerns** (`app/controllers/concerns/`): Share common functionality
   - `Filterable`: Provides common filtering methods across controllers

4. **Policy Classes** (`app/policies/`): Handle authorization logic
   - `StudentPolicy`: Defines who can view, edit, or delete students

5. **Helpers** (`app/helpers/`): Application-wide helper methods
   - `ApplicationHelper`: Common formatting methods

### Technology Stack

- **Framework**: Ruby on Rails 8.0
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq with Redis
- **Frontend**: Hotwire (Turbo, Stimulus) for modern web interactions
- **Styling**: CSS with the same color palette as the React app
- **Containerization**: Docker and Docker Compose

## Setup

### Prerequisites

- Ruby 3.3.3
- PostgreSQL
- Redis
- Docker (optional, for containerized deployment)

### Local Development

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Set up the database:
   ```bash
   rails db:create
   rails db:migrate
   ```
4. Start the application:
   ```bash
   rails server
   ```

### Docker Setup

For production-like environment:

1. Build and start the services:
   ```bash
   docker-compose -f docker-compose.dev.yml up
   ```

## Environment Variables

Create a `.env` file with the following variables:

```
RAILS_MASTER_KEY=your_master key from config/master.key
DB_HOST=localhost
DB_USERNAME=postgres
DB_PASSWORD=password
REDIS_URL=redis://localhost:6379/0
```

## Background Jobs

This application uses Sidekiq for background job processing:

1. Start Sidekiq:
   ```bash
   bundle exec sidekiq
   ```

Background jobs are used for:
- Sending attendance notifications
- Fee reminders
- Event notifications

## Deployment

This application is configured for deployment with Kamal. To deploy:

1. Update `config/deploy.yml` with your server details
2. Deploy with:
   ```bash
   bin/kamal deploy
   ```

## Color Palette

The application uses the same color palette as the React app:

- Primary: #1e1f24 (dark slate)
- Background: #f5f4f2 (soft porcelain)
- Secondary: #a8c1b7 (gentle sage)
- Accent: #dcc9a2 (warm sandstone)
- Baby blue: #bfd6ea
- Rose: #e8cbd6

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License.