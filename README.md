# KidGarden ERP

A comprehensive Enterprise Resource Planning (ERP) system specifically designed for kindergartens and early childhood establishments. Built with Ruby on Rails 8, KidGarden aims to bridge the digital gap in the education sector by providing a professional, modern, and user-friendly platform for administrators, teachers, and parents.

![KidGarden Login](kidgarden_login_dark_mode.png)

## 🚀 Overview

KidGarden is more than just a management tool; it's a complete ecosystem for educational institutions. It replaces fragmented communication (like WhatsApp groups) and manual record-keeping with an integrated solution tailored for the local market context.

## ✨ Key Features

### 👥 Entity Management
- **Student Profiles**: Comprehensive records including medical alerts, emergency contacts, and classroom assignments.
- **Parent Portal**: Linked accounts for families with multiple children.
- **Staff Management**: Role-based access control for administrators, teachers, and support staff.

### 📅 Attendance & Operations
- **Digital Attendance**: Real-time check-in/out tracking with status and notes.
- **Event Calendar**: Integrated system for school trips, holidays, and parent meetings.
- **Classroom Management**: Organize students and teachers into dedicated learning environments.

### 💰 Financial Engine
- **Automated Invoicing**: Generate monthly invoices with itemized fees.
- **Payment Tracking**: Monitor "Paid" vs "Pending" statuses with detailed transaction history.
- **Discount System**: Support for multi-child (sibling) discounts and custom fee adjustments.
- **Payment Reminders**: Automated notifications for upcoming or overdue payments.

### 💬 Communication & Engagement
- **Real-time Messaging**: Secure internal conversation system with read receipts.
- **Photo & Document Sharing**: Privacy-controlled galleries for sharing classroom moments and important documents.
- **Announcement Board**: Dashboard-integrated school-wide updates.

## 🛠 Technology Stack

- **Framework**: Ruby on Rails 8.0
- **Database**: PostgreSQL (Primary) & Redis (Caching/Background Jobs)
- **Background Jobs**: Sidekiq
- **Frontend**: Hotwire (Turbo & Stimulus) for a SPA-like experience without complex JS frameworks.
- **Styling**: Tailwind-inspired custom CSS with a professional "Notion-like" aesthetic.
- **Storage**: Active Storage with support for local or cloud providers.
- **Deployment**: Containerized with Docker and orchestrated with Kamal.

## 🎨 Color Palette

The application uses a carefully curated palette to ensure a warm yet professional feel:

- **Primary**: `#1e1f24` (Dark Slate) - Professional hierarchy
- **Background**: `#f5f4f2` (Soft Porcelain) - Clean workspace
- **Secondary**: `#a8c1b7` (Gentle Sage) - Calm interactions
- **Accent**: `#dcc9a2` (Warm Sandstone) - Highlights
- **Playful Tones**: `#bfd6ea` (Baby Blue) and `#e8cbd6` (Rose)

## ⚙️ Setup & Installation

### Prerequisites
- Ruby 3.3.3
- PostgreSQL 14+
- Redis
- Docker (Optional)

### Local Development
1. **Clone the repository**:
   ```bash
   git clone <repo-url>
   cd kidGarden
   ```
2. **Install dependencies**:
   ```bash
   bundle install
   ```
3. **Configure Environment**:
   Copy the sample environment file and update your credentials:
   ```bash
   cp .env.example .env # If available, otherwise create one
   ```
4. **Database Setup**:
   ```bash
   rails db:prepare
   rails db:seed # Includes sample data for testing
   ```
5. **Start the Engines**:
   ```bash
   # Run Rails, Sidekiq, and CSS watcher in parallel
   bin/dev
   ```

### Docker Setup
For a production-like environment:
```bash
docker-compose -f docker-compose.dev.yml up --build
```

## 📈 Project Roadmap

Currently, KidGarden is at **~45% completion**.

- ✅ **Phase 1 (Core Foundation)**: 100% Complete
- 🔄 **Phase 2 (Financial & Operations)**: 60% Complete (Invoicing/Payments done, Inventory pending)
- 🔄 **Phase 3 (Engagement & Analytics)**: 25% Complete (Messaging/Photos done)
- ⏳ **Phase 4 (Advanced Features)**: Planned

See [KIDGARDEN_ROADMAP.md](KIDGARDEN_ROADMAP.md) for the detailed 12-month vision.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
